import Social

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
    var difficulty: Int = 30 // chance of having a block - the higher the more difficult to play
    var gameTime: Int = 0

    //Character
    weak var character: Character!
    var characterLevel: CGFloat = 243//boat 239
    var divingSpeed: CGFloat = 0
    var defaultDivingSpeed: CGFloat = 4.5
    var isCatching: Bool = false

    //Fish
    //   Field:
    var screenSize: CGRect!

    var distanceBetweenFishesX: CGFloat!
    var distanceBetweenFishesY: CGFloat!

    var chanceOfTwoFishInARow: CGFloat! = 0.3

    //  Layers: borderOne is the first/highest layer
    var maxLevel: CGFloat = 235
    var borderOne: CGFloat = 230
    var borderTwo: CGFloat = 45
    var minLevel: CGFloat = 25
    
    var pointsOne: CGFloat = 0
    var pointsTwo: CGFloat = 1
    var pointsMin: CGFloat = 101

    //  Y-axis Position:
    
    var wavesArray: [[Fish!]] = []

    var levelOneFish: FishLevelOne!
    var levelTwoFish: FishLevelTwo!
    var minLevelFish: FishMinLevel!

    var loadFishArray: [Fish!] = []
    
    var waveNumber: Int = 0

    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        character.position.y = characterLevel
        userInteractionEnabled = true
        waterArray.append(water1)
        waterArray.append(water2)

        // Assigning value to the declared variables
        levelOneFish = CCBReader.load("FishLevelOne") as! FishLevelOne
        levelTwoFish = CCBReader.load("FishLevelTwo") as! FishLevelTwo
//        levelDeadFish = CCBReader.load("FishLevelDead") as! FishLevelDead
        minLevelFish = CCBReader.load("FishMinLevel") as! FishMinLevel

        levelOneFish.upperBorder = maxLevel
        levelOneFish.lowerBorder = borderOne


        levelTwoFish.upperBorder = borderOne
        levelTwoFish.lowerBorder = borderTwo


        minLevelFish.upperBorder = borderTwo
        minLevelFish.lowerBorder = minLevel


        loadFishArray.append(levelOneFish)
        loadFishArray.append(levelTwoFish)
        loadFishArray.append(minLevelFish)

        // Assigning distance between fishes
        distanceBetweenFishesX = 75 //6 times higher than size
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
        spawnInitialWaves()
        
//        gamePhysicsNode.debugDraw = true
        
    }

    //    TODO - re-spawning distance
    
    func spawnWave(column: Int!) {
        var wave: [Fish!] = []
        let fish = CCBReader.load("FishLevelOne") as! FishLevelOne
        fish.position.y = maxLevel
        fish.position.x = CGFloat(column) * levelTwoFish.columnSize
        fish.points = pointsOne
        
        gamePhysicsNode.addChild(fish)
        wave.append(fish)
        
        
        for fishRow in 1...Int(levelTwoFish.numberOfRows) {
            var visibleChance = arc4random_uniform(100)
            if visibleChance < UInt32(difficulty) {
                let fish2 = CCBReader.load("FishLevelTwo") as! FishLevelTwo
                fish2.position.y = borderOne - (levelTwoFish.rowSize * CGFloat(fishRow))
                fish2.position.x = CGFloat(column) * levelTwoFish.columnSize
                fish2.points = pointsTwo
                
                gamePhysicsNode.addChild(fish2)
                wave.append(fish2)
            }
        }
        
        let fish3 = CCBReader.load("FishMinLevel") as! FishMinLevel
        fish3.position.y = minLevel
        fish3.position.x = CGFloat(column) * levelTwoFish.columnSize
        fish3.points = pointsMin
        
        gamePhysicsNode.addChild(fish3)
        wave.append(fish3)
        
        wavesArray.append(wave)
        
    }
    
    func spawnInitialWaves() {
        for column in Int(levelOneFish.numberOfColumns)...Int(levelOneFish.numberOfColumns) * 2 {
            waveNumber += 1
            spawnWave(waveNumber)
            
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

        for fish in wavesArray[0] {
            let fishWorldPosition = gamePhysicsNode.convertToWorldSpace(fish.position)
            let fishScreenPosition = convertToNodeSpace(fishWorldPosition)
            if fishScreenPosition.x <= (-fish.contentSize.width) {
                waveNumber++
                spawnWave(waveNumber)
                wavesArray.removeAtIndex(0)
                println(waveNumber)
            }
        }
        

//        
//        
//        gameTime++
//        println(gameTime)

        timeLeft -= Float(delta / 2)
        if timeLeft <= 0 {
            gameOver()
        }
        
        // Game difficulty
        if waveNumber < 40 {
            difficulty = 30
            scrollSpeed = 4.5
        } else if waveNumber < 50 {
            difficulty = 32
            scrollSpeed = 5.0
        } else if waveNumber < 85 {
            difficulty = 35
            scrollSpeed = 5.0
        } else if waveNumber < 110 {
            difficulty = 37
            scrollSpeed = 5.5
        } else {
            difficulty = 42
            scrollSpeed = 5.5
        }
    }

    func restart() {
        let scene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(scene)
    }

    func shareButtonTapped() {
        var scene = CCDirector.sharedDirector().runningScene
        var n: AnyObject = scene.children[0]
        var image = screenShotWithStartNode(n as! CCNode)
        
        let sharedText = "Share text"
        let itemsToShare = [image, sharedText]
        
        var excludedActivities = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop]
        
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivities
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        var viewSize = CCDirector.sharedDirector().viewSize()
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height))
        rtx.begin()
        node.visit()
        rtx.end()
        return rtx.getUIImage()
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
    
//    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishLevelDead: Fish!, character: Character!) -> Bool {
//        fishLevelDead.removeFromParent()
//        let bonusTime: Float = Float(fishLevelDead.points/CGFloat(60)) // 25 points - 2.5 minute
//        timeLeft += bonusTime
//        points += NSInteger(fishLevelDead.points)
//        scoreLabel.string = String(points)
//        isCatching = true
//        fishLevelDead.position.x += levelDeadFish.moveDistance
//        
//        return true
//    }

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

