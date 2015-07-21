class Gameplay: CCNode, CCPhysicsCollisionDelegate {
    //Interface
    enum gameState {
        case Play, Pause, Mainscene, Gameover
    }
    
    weak var restartButton: CCButton!
    weak var energyBar: CCSprite!
    var timeLeft: Float = 3 {
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
    
    //Environment
    weak var water1: CCNodeGradient!
    weak var water2: CCNodeGradient!
    var waterArray: [CCNodeGradient!] = []
    
    //Physics
    weak var gamePhysicsNode: CCPhysicsNode!
    var scrollSpeed: CGFloat = 3
    
    //Character
    weak var character: Character!
    var characterLevel: CGFloat = 265//boat 239
    var divingSpeed: CGFloat = 0
    var defaultDivingSpeed: CGFloat = 5
    var isCatching: Bool = false
    
    //Fish
    //   Field:
    var screenSize: CGRect!

    var distanceBetweenFishesX: CGFloat!
    var distanceBetweenFishesY: CGFloat!
    
    var chanceOfTwoFishInARow: CGFloat! = 0.3

    //  Layers: borderOne is the first/highest layer
    var maxLevel: CGFloat = 245
    var borderOne: CGFloat = 240
    var borderTwo: CGFloat = 30
    var minLevel: CGFloat = 10

    //  Y-axis Position:

    var fishArrayT: [Fish!] = []
//    var prevLevelOnePosition: CGFloat = 0
//    var nextLevelOnePosition: CGFloat!

    var fishArrayM: [Fish!] = []
//    var prevLevelTwoPosition: CGFloat = 100
//    var nextLevelTwoPosition: CGFloat!
    
    var fishArrayB: [Fish!] = []
//    var prevMinLevelPosition: CGFloat = 100
//    var nextMinLevelPosition: CGFloat!
    
    var levelOneFish: FishLevelOne!
    var levelTwoFish: FishLevelTwo!
    var minLevelFish: FishMinLevel!
    
    var loadFishArray: [Fish!] = []
    
    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        character.position.y = characterLevel
        userInteractionEnabled = true
        waterArray.append(water1)
        waterArray.append(water2)
        
        // Assigning value to the declared variables
        levelOneFish = CCBReader.load("FishLevelOne") as! FishLevelOne
        levelTwoFish = CCBReader.load("FishLevelTwo") as! FishLevelTwo
        minLevelFish = CCBReader.load("FishMinLevel") as! FishMinLevel
        
        levelOneFish.upperBorder = 245
        levelOneFish.lowerBorder = 240
        

        levelTwoFish.upperBorder = 240
        levelTwoFish.lowerBorder = 30

        
        minLevelFish.upperBorder = 30
        minLevelFish.lowerBorder = 10
        
        
        loadFishArray.append(levelOneFish)
        loadFishArray.append(levelTwoFish)
        loadFishArray.append(minLevelFish)
        
        // Assigning distance between fishes
        distanceBetweenFishesX = 25
        distanceBetweenFishesY = character.contentSize.height * 0.5

        // Calculating gird cells' size for different layers
        screenSize = UIScreen.mainScreen().bounds
        
        for fish in loadFishArray {
            fish.rowSize = fish.contentSize.height + distanceBetweenFishesY
            fish.columnSize = fish.contentSize.width + distanceBetweenFishesX

            var levelHeight = fish.upperBorder - fish.lowerBorder
            fish.numberOfRows = levelHeight / fish.rowSize

            fish.numberOfColumns = screenSize.width / fish.columnSize
            
            fish.moveDistance = fish.columnSize * fish.numberOfColumns + distanceBetweenFishesX
            
        }
        
        // Spawning the fishes that automatically moves forward after leaving the screen or collision - func moveForward()
        
        spawnLevelOneFish()
        spawnLevelTwoFish()
        spawnMinLevelFish()
    }
    
//    TODO - re-spawning distance
    
    func spawnLevelOneFish() {
        var count = 1
        for column in 0...Int(levelOneFish.numberOfColumns) {
            count++
            
            let fish = CCBReader.load("FishLevelOne") as! FishLevelOne
            fish.position.y = maxLevel
            fish.position.x = levelOneFish.columnSize * CGFloat(column)
            fish.points = 5
            gamePhysicsNode.addChild(fish)
            fishArrayT.append(fish)
        }
    }
    
    func spawnLevelTwoFish() {
        for fishColumn in 1...Int(levelTwoFish.numberOfColumns) {
            for fishRow in 1...Int(levelTwoFish.numberOfRows) {
                let fish = CCBReader.load("FishLevelTwo") as! FishLevelTwo
                fish.position.y = borderOne - (levelTwoFish.rowSize * CGFloat(fishRow))
                fish.position.x = levelTwoFish.columnSize * CGFloat(fishColumn)
                fish.points = 10
                gamePhysicsNode.addChild(fish)
                fishArrayM.append(fish)
            }
        }
    }
    
    func spawnMinLevelFish() {
        for fishColumn in 1...Int(minLevelFish.numberOfColumns) {
            let fish = CCBReader.load("FishMinLevel") as! FishMinLevel
            fish.position.y = minLevel
            fish.position.x = minLevelFish.columnSize * CGFloat(fishColumn)
            fish.points = 50
            gamePhysicsNode.addChild(fish)
            fishArrayB.append(fish)
        }
        
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if touch.locationInWorld().x <= screenSize.width / 2 {
            if character.position.y >= characterLevel {
                divingSpeed = 0
            } else {divingSpeed = defaultDivingSpeed}
        } else {
            if character.position.y <= minLevel {divingSpeed = 0}
            else {divingSpeed = -defaultDivingSpeed}
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        divingSpeed = 0
    }
    
    override func update(delta: CCTime) {
        
        // Scrolling the World and Character
        let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(divingSpeed), Float(divingSpeed))
        
        if character.position.y <= minLevel {
            character.position.y = minLevel
        } else if character.position.y >= characterLevel {
            character.position.y = characterLevel
        }

        gamePhysicsNode.position.x -= scrollSpeed
        character.position.x += scrollSpeed
        
        
        // If isCatching, then no controll is allowed
        if isCatching == false {
            character.position.y += divingSpeed
        } else {
            if character.position.y <= characterLevel {
                character.position.y += defaultDivingSpeed // return to initial stage
            }
        }
        
        // Top limitations for character
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
        
//        println(fishArrayM.count)
//        
        for fish in fishArrayT {
            let fishWorldPosition = gamePhysicsNode.convertToWorldSpace(fish.position)
            let fishScreenPosition = convertToNodeSpace(fishWorldPosition)
            if fishScreenPosition.x <= (-fish.contentSize.width) {
                println()
                println(fish.position.x)
                fish.position.x += levelOneFish.moveDistance
                println(fish.position.x)
                println(levelOneFish.moveDistance)
            }
        }
        
        timeLeft -= Float(delta / 2)
        if timeLeft <= 0 {
            gameOver()
        }
    }
    
    func restart() {
        let scene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(scene)
    }

    func share() {
    
    }

    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishLevelOne: Fish!, character: Character!) -> Bool {
        fishLevelOne.removeFromParent()
        let bonusTime: Float = Float(fishLevelOne.points/CGFloat(60)) // 25 points - 2.5 minute
        timeLeft += bonusTime
        points += NSInteger(fishLevelOne.points)
        scoreLabel.string = String(points)
        isCatching = true
        fishLevelOne.position.x += levelOneFish.moveDistance
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishLevelTwo: Fish!, character: Character!) -> Bool {
        fishLevelTwo.removeFromParent()
        let bonusTime: Float = Float(fishLevelTwo.points/CGFloat(60)) // 25 points - 2.5 minute
        timeLeft += bonusTime
        points += NSInteger(fishLevelTwo.points)
        scoreLabel.string = String(points)
        isCatching = true
        fishLevelTwo.position.x += levelOneFish.moveDistance
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishMinLevel: Fish!, character: Character!) -> Bool {
        let bonusTime: Float = Float(fishMinLevel.points/CGFloat(60)) // 25 points - 2.5 minute
        timeLeft += bonusTime
        points += NSInteger(fishMinLevel.points)
        scoreLabel.string = String(points)
        isCatching = true
        fishMinLevel.removeFromParent()
        fishMinLevel.position.x += levelOneFish.moveDistance
        
        return true
    }
    
    func gameOver() {
        paused = true
        restartButton.visible = false
        gameOverScreen.visible = true
        yourScore.string = scoreLabel.string
        if points > GameStatistics.bestPoints {
            GameStatistics.bestPoints = points
        }
        bestScore.string = String(GameStatistics.bestPoints)
        scoreLabel.visible = false
    }
}

