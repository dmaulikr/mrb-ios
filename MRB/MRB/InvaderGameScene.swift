//
//  GameScene.swift
//  MRB
//
//  Created by Ethan Look on 12/13/14.
//  Copyright (c) 2014 Ethan Look. All rights reserved.
//

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let UFO   : UInt32 = 0b1       // 1
    static let Rocket: UInt32 = 0b10      // 2
    static let Blockade: UInt32 = 0b11      // 3
}

import SpriteKit
import iAd

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class InvaderGameScene: SKScene, SKPhysicsContactDelegate {
 
    var gameOver:Bool
    var loseMessage:String
    var loseLabel:SKLabelNode
    var scoreMessage:String
    var scoreLabel:SKLabelNode
    var highScoreMessage:String
    var highScoreLabel:SKLabelNode
    var menuMessage:String
    var menuLabel:SKLabelNode
    var topBar:SKSpriteNode
    var score:Int
    var rocketsRemaining:Int
    var maxRockets:Int
    var timeStamp:Int
    var powerUpTimeStamp:Int
    var starCount:Int
    var invaderHighScores:HighScoreManager
    var addRocketPowerUpTimer: Int
    var addRocketPowerUp: Bool
    var shootMegaRocket: Bool
    var blink: SKAction
    
    override init(size: CGSize) {
        gameOver = false
        loseMessage = "YOU LOSE"
        loseLabel = SKLabelNode(fontNamed: "Futura-Medium")
        score = 0
        maxRockets = 3
        rocketsRemaining = 0
        scoreMessage = "Score: \(score)"
        scoreLabel = SKLabelNode(fontNamed: "Futura-Medium")
        timeStamp = 0
        powerUpTimeStamp = 0
        highScoreMessage = "High score!"
        highScoreLabel = SKLabelNode(fontNamed: "Futura-Medium")
        menuMessage = "HOME"
        menuLabel = SKLabelNode(fontNamed: "Futura-Medium")
        invaderHighScores = HighScoreManager()
        topBar = SKSpriteNode(imageNamed: "Top_Bar")
        
        addRocketPowerUpTimer = 1
        addRocketPowerUp = false
        
        shootMegaRocket = false

        starCount = 150
        
        blink = SKAction()
        
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("hideAd", object: nil)
        
        backgroundColor = SKColor.blackColor()
        
        loseLabel.text = loseMessage
        loseLabel.fontSize = 40
        loseLabel.fontColor = SKColor.whiteColor()
        loseLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 40)
        loseLabel.zPosition = 3.0
        loseLabel.hidden = true
        self.addChild(self.loseLabel)
        
        highScoreLabel.text = highScoreMessage
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = SKColor.yellowColor()
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        highScoreLabel.zPosition = 3.0
        highScoreLabel.name = "High_Score_Label"
        blink = SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(0.5), SKAction.fadeInWithDuration(0.5)]))
        
        topBar.zPosition = 2.0
        topBar.position = CGPointMake(self.size.width/2, self.size.height - topBar.size.height/2)
        topBar.name = "topBar"
        self.addChild(topBar)
        
        menuLabel.text = menuMessage
        menuLabel.fontSize = 18
        menuLabel.fontColor = SKColor.whiteColor()
        menuLabel.position = CGPoint(x: size.width - (topBar.frame.height - menuLabel.frame.height)/2 - menuLabel.frame.width/2, y: self.size.height - topBar.frame.height/2  - menuLabel.frame.height/2)
        menuLabel.zPosition = 3.0
        menuLabel.name = "menu"
        self.addChild(self.menuLabel)
        
        scoreLabel.text = scoreMessage
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height - topBar.frame.height/2  - scoreLabel.frame.height/2)
        scoreLabel.zPosition = 3.0
        self.addChild(scoreLabel)
        
        addAgainButton()
        addStars(starCount)
        
        for var i = rocketsRemaining; i < maxRockets; i++ {
            addRocketRemaining()
        }
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addUFO(diff: Float) {
        
        // Create sprite
        let ufo = SKSpriteNode(imageNamed: "ufo")
        ufo.zPosition = 0.0
        
        let row1 = SKPhysicsBody(rectangleOfSize: CGSize(width: ufo.size.width/3, height: ufo.size.height/8), center: CGPoint(x: 0, y: ufo.size.height*7/16))
        let row2 = SKPhysicsBody(rectangleOfSize: CGSize(width: ufo.size.width*7/15, height: ufo.size.height/8), center: CGPoint(x: 0, y: ufo.size.height*5/16))
        let row3 = SKPhysicsBody(rectangleOfSize: CGSize(width: ufo.size.width*3/5, height: ufo.size.height/8), center: CGPoint(x: 0, y: ufo.size.height*3/16))
        let row4 = SKPhysicsBody(rectangleOfSize: CGSize(width: ufo.size.width*13/15, height: ufo.size.height/8), center: CGPoint(x: 0, y: ufo.size.height/16))
        let row5 = SKPhysicsBody(rectangleOfSize: CGSize(width: ufo.size.width, height: ufo.size.height/8), center: CGPoint(x: 0, y: -ufo.size.height / 16))
        ufo.physicsBody = SKPhysicsBody(bodies: [row1, row2, row3, row4, row5])
        ufo.physicsBody?.dynamic = true
        ufo.physicsBody?.categoryBitMask = PhysicsCategory.UFO
        ufo.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket | PhysicsCategory.Blockade
        ufo.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the UFO along the X axis
        let actualX = random(min: ufo.size.width/2, max: size.width - ufo.size.width/2)
        
        // Position the UFO slightly off-screen along the top edge,
        // and along a random position along the X axis as calculated above
        let initialPosition = CGPoint(x: actualX, y: size.height + ufo.size.width/2 - 50)
        ufo.position = initialPosition
        
        ufo.name = "ufo"
        
        // Add the UFO to the scene
        addChild(ufo)
        
        // Determine speed of the UFO
        let actualDuration = random(min: CGFloat(2.0 - diff), max: CGFloat(4.0 - 2.0 * diff + 0.01))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: random(min: ufo.size.width/2, max: size.width - ufo.size.width/2), y: -ufo.size.height/2), duration: NSTimeInterval(actualDuration))
        let loseAction = SKAction.runBlock() {
            if (!self.gameOver) {
                var currentHighScore = 0
                for i in self.invaderHighScores.scores {
                    if (i.score > currentHighScore) {
                        currentHighScore = i.score
                    }
                }
                if (self.score > currentHighScore) {
                    self.highScoreLabel.runAction(self.blink)
                    self.addChild(self.highScoreLabel)
                }
                self.loseLabel.hidden = false
                self.invaderHighScores.addNewScore(self.score)
                self.printHighScores(self.invaderHighScores)
                self.childNodeWithName("Again_Button")?.hidden = false
                self.gameOver = true
                NSNotificationCenter.defaultCenter().postNotificationName("showAd", object: nil)
            }
            ufo.removeFromParent()
        }
        ufo.runAction(SKAction.sequence([actionMove, loseAction]))
    }
    
    func addFallingBlockade() {
        let fallingBlockade = SKSpriteNode(imageNamed: "Condensed_Blockade")
        fallingBlockade.zPosition = 0.0
        
        fallingBlockade.physicsBody = SKPhysicsBody(rectangleOfSize: fallingBlockade.size)
        fallingBlockade.physicsBody?.dynamic = true
        fallingBlockade.physicsBody?.categoryBitMask = PhysicsCategory.UFO
        fallingBlockade.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        fallingBlockade.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: fallingBlockade.size.width/2, max: size.width - fallingBlockade.size.width/2)
        let initialPosition = CGPoint(x: actualX, y: size.height + fallingBlockade.size.width/2 - 50)
        fallingBlockade.position = initialPosition
        
        fallingBlockade.name = "fallingBlockade"
        
        let tapArea = SKSpriteNode()
        tapArea.size = CGSize(width: 1.2 * fallingBlockade.size.width, height: 1.2 * fallingBlockade.size.height)
        tapArea.name = "fallingBlockadeTapArea"
        fallingBlockade.addChild(tapArea)
        
        addChild(fallingBlockade)
        
        let actualDuration = random(min: CGFloat(4), max: CGFloat(5))
        
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: -fallingBlockade.size.width/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock() {
            fallingBlockade.removeFromParent()
        }
        fallingBlockade.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addBlockade(location: CGPoint) {
        let blockade = SKSpriteNode(imageNamed: "Blockade")
        blockade.zPosition = 0.0
        blockade.position = location
        blockade.name = "blockade"
        
        blockade.physicsBody = SKPhysicsBody(rectangleOfSize: blockade.size)
        blockade.physicsBody?.dynamic = true
        blockade.physicsBody?.categoryBitMask = PhysicsCategory.Blockade
        blockade.physicsBody?.contactTestBitMask = PhysicsCategory.UFO
        blockade.physicsBody?.collisionBitMask = PhysicsCategory.None
        blockade.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(blockade)
        let removal = SKAction.runBlock() {
            self.addExplosion(blockade)
            blockade.removeFromParent()
        }
        let waiting = SKAction.waitForDuration(5.0)
        let displayBlockade = SKAction.runBlock() {
            blockade.hidden = false
        }
        let hideBlockade = SKAction.runBlock() {
            blockade.hidden = true
        }
        let blinkWait = SKAction.waitForDuration(NSTimeInterval(0.125))
        let blink = SKAction.repeatAction(SKAction.sequence([hideBlockade, blinkWait, displayBlockade, blinkWait]), count: 4)
        blockade.runAction(SKAction.sequence([waiting, blink, removal]))
    }
    
    func addFallingBomb() {
        let fallingBomb = SKSpriteNode(imageNamed: "Condensed_Bomb")
        fallingBomb.zPosition = 0.0
        
        fallingBomb.physicsBody = SKPhysicsBody(rectangleOfSize: fallingBomb.size)
        fallingBomb.physicsBody?.dynamic = true
        fallingBomb.physicsBody?.categoryBitMask = PhysicsCategory.UFO
        fallingBomb.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        fallingBomb.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: fallingBomb.size.width/2, max: size.width - fallingBomb.size.width/2)
        let initialPosition = CGPoint(x: actualX, y: size.height + fallingBomb.size.width/2 - 50)
        fallingBomb.position = initialPosition
        
        fallingBomb.name = "fallingBomb"
        
        let tapArea = SKSpriteNode()
        tapArea.size = CGSize(width: 1.2 * fallingBomb.size.width, height: 1.2 * fallingBomb.size.height)
        tapArea.name = "fallingBombTapArea"
        fallingBomb.addChild(tapArea)
        addChild(fallingBomb)
        
        let actualDuration = random(min: CGFloat(4), max: CGFloat(5))
        
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: -fallingBomb.size.width/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock() {
            fallingBomb.removeFromParent()
        }
        fallingBomb.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addRocketRemainingPowerUp() {
        let rocketRemainingPowerUp = SKSpriteNode(imageNamed: "Rocket_Power_Up")
        rocketRemainingPowerUp.zPosition = 0.0
        
        rocketRemainingPowerUp.physicsBody = SKPhysicsBody(rectangleOfSize: rocketRemainingPowerUp.size)
        rocketRemainingPowerUp.physicsBody?.dynamic = true
        rocketRemainingPowerUp.physicsBody?.categoryBitMask = PhysicsCategory.UFO
        rocketRemainingPowerUp.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        rocketRemainingPowerUp.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: rocketRemainingPowerUp.size.width/2, max: size.width - rocketRemainingPowerUp.size.width/2)
        let initialPosition = CGPoint(x: actualX, y: size.height + rocketRemainingPowerUp.size.width/2 - 50)
        rocketRemainingPowerUp.position = initialPosition
        
        rocketRemainingPowerUp.name = "fallingRocketRemaining"
        
        let tapArea = SKSpriteNode()
        tapArea.size = CGSize(width: 1.2 * rocketRemainingPowerUp.size.width, height: 1.2 * rocketRemainingPowerUp.size.height)
        tapArea.name = "fallingRocketRemainingTapArea"
        rocketRemainingPowerUp.addChild(tapArea)
        
        addChild(rocketRemainingPowerUp)
        
        let actualDuration = random(min: CGFloat(4), max: CGFloat(5))
        
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: -rocketRemainingPowerUp.size.width/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock() {
            rocketRemainingPowerUp.removeFromParent()
        }
        rocketRemainingPowerUp.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addFallingMegaRocket() {
        let fallingMegaRocket = SKSpriteNode(imageNamed: "Condensed_Mega_Rocket")
        fallingMegaRocket.zPosition = 0.0
        
        fallingMegaRocket.physicsBody = SKPhysicsBody(rectangleOfSize: fallingMegaRocket.size)
        fallingMegaRocket.physicsBody?.dynamic = true
        fallingMegaRocket.physicsBody?.categoryBitMask = PhysicsCategory.UFO
        fallingMegaRocket.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        fallingMegaRocket.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: fallingMegaRocket.size.width/2, max: size.width - fallingMegaRocket.size.width/2)
        let initialPosition = CGPoint(x: actualX, y: size.height + fallingMegaRocket.size.width/2 - 50)
        fallingMegaRocket.position = initialPosition
        
        fallingMegaRocket.name = "fallingMegaRocket"
        
        let tapArea = SKSpriteNode()
        tapArea.size = CGSize(width: 1.2 * fallingMegaRocket.size.width, height: 1.2 * fallingMegaRocket.size.height)
        tapArea.name = "fallingMegaRocketTapArea"
        fallingMegaRocket.addChild(tapArea)
        
        addChild(fallingMegaRocket)
        
        let actualDuration = random(min: CGFloat(4), max: CGFloat(5))
        
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: -fallingMegaRocket.size.width/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock() {
            fallingMegaRocket.removeFromParent()
        }
        fallingMegaRocket.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addRocketRemaining() {
        if (rocketsRemaining < maxRockets) {
            let remainingRocket = SKSpriteNode(imageNamed: "rocket")
            remainingRocket.size.width = 0.5 * remainingRocket.size.width
            remainingRocket.size.height = 0.5 * remainingRocket.size.height
            remainingRocket.zPosition = 3.0
            
            let y = size.height - topBar.frame.height/2
            
            var x = CGFloat(0.0)
            if (rocketsRemaining == 0) {
                x = 2 * (topBar.frame.height - remainingRocket.frame.height)/4 + remainingRocket.frame.width/2
                remainingRocket.name = "Remaining_Rocket1"
            } else if (rocketsRemaining == 1) {
                x = 3 * (topBar.frame.height - remainingRocket.frame.height)/4 + 3 * remainingRocket.frame.width/2
                remainingRocket.name = "Remaining_Rocket2"
            } else if (rocketsRemaining == 2) {
                x = 4 * (topBar.frame.height - remainingRocket.frame.height)/4 + 5 * remainingRocket.frame.width/2
                remainingRocket.name = "Remaining_Rocket3"
            }
            
            remainingRocket.position = CGPoint(x: x, y: y)
            addChild(remainingRocket)
            
            rocketsRemaining++
        }
    }
    
    func removeRocketRemaining() {
        if (rocketsRemaining == 3) {
            self.childNodeWithName("Remaining_Rocket3")?.removeFromParent()
        } else if (rocketsRemaining == 2) {
            self.childNodeWithName("Remaining_Rocket2")?.removeFromParent()
        } else if (rocketsRemaining == 1) {
            self.childNodeWithName("Remaining_Rocket1")?.removeFromParent()
        }
        rocketsRemaining--
    }
    
    func addStars(starCount: Int) {
        for _ in 0...starCount {
            let star = SKSpriteNode(imageNamed: "Particle")
            let starX = random(min: CGFloat(0.0), max: size.width)
            let starY = random(min: CGFloat(0.0), max: size.height)
            let starScale = random(min: CGFloat(0.5), max: CGFloat(1.5))
            star.size.width = starScale * star.size.width
            star.size.height = starScale * star.size.height
            star.position = CGPoint(x: starX, y: starY)
            star.zPosition = -1.0
            addChild(star)
            let actualDuration = random(min: CGFloat(12), max: CGFloat(14))
            
            let actionMove = SKAction.moveTo(CGPoint(x: starX, y: self.size.height + star.size.width/2 + starY), duration: NSTimeInterval(actualDuration))
            let actionMoveDone = SKAction.runBlock() {
                star.removeFromParent()
            }
            star.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func addStar() {
        let star = SKSpriteNode(imageNamed: "Particle")
        let starX = random(min: CGFloat(0.0), max: size.width)
        let starScale = random(min: CGFloat(0.5), max: CGFloat(1.5))
        star.size.width = starScale * star.size.width
        star.size.height = starScale * star.size.height
        star.position = CGPoint(x: starX, y: -star.size.height/2)
        star.zPosition = -1.0
        addChild(star)
        let actualDuration = random(min: CGFloat(12), max: CGFloat(14))
        
        let actionMove = SKAction.moveTo(CGPoint(x: starX, y: self.size.height + star.size.width/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock() {
            star.removeFromParent()
        }
        star.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addAgainButton() {
        
        let againButton = SKSpriteNode(imageNamed: "Again_Button")
        
        againButton.position = CGPoint(x: size.width/2, y: size.height/2 - 70)
        
        againButton.name = "Again_Button"
        
        againButton.zPosition = 2.0
        
        againButton.hidden = true
        
        addChild(againButton)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        for child in self.children {
            if (child.name == "menu") {
                if (child.containsPoint(touchLocation)) {
                    let menuScene = MenuScene(size: self.size)
                    self.view?.presentScene(menuScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 1.75))
                }
            }
        }
        
        if (!gameOver) {
            var dontFireRocket = false
            
            for child in self.children {
                if (child.name == "topBar") {
                    if (child.containsPoint(touchLocation)) {
                        dontFireRocket = true
                    }
                }
            }
            if (rocketsRemaining > 0 && !dontFireRocket && !shootMegaRocket) {
                let rocket = SKSpriteNode(imageNamed: "rocket")
                rocket.position = touchLocation
                rocket.zPosition = 0.0
                rocket.name = "rocket"
                
                rocket.physicsBody = SKPhysicsBody(circleOfRadius: rocket.size.width/2)
                rocket.physicsBody?.dynamic = true
                rocket.physicsBody?.categoryBitMask = PhysicsCategory.Rocket
                rocket.physicsBody?.contactTestBitMask = PhysicsCategory.UFO
                rocket.physicsBody?.collisionBitMask = PhysicsCategory.None
                rocket.physicsBody?.usesPreciseCollisionDetection = true
                
                self.removeRocketRemaining()
                
                addChild(rocket)
                
                let direction = CGPoint(x: 0, y: 1)
                
                let shootAmount = direction * (self.size.height + 100)
                
                let realDest = shootAmount + rocket.position
                
                let actionMove = SKAction.moveTo(realDest, duration: 12.0)
                let actionAccel = SKAction.speedBy(50, duration: 12.0)
                let actionMoveDone = SKAction.runBlock() {
                    rocket.removeFromParent()
                }
                rocket.runAction(SKAction.sequence([SKAction.group([actionMove,actionAccel]), actionMoveDone]))
            }
            if (!dontFireRocket && shootMegaRocket) {
                let megaRocket = SKSpriteNode(imageNamed: "mega_rocket")
                megaRocket.position = touchLocation
                megaRocket.zPosition = 0.0
                megaRocket.name = "megaRocket"
                
                megaRocket.physicsBody = SKPhysicsBody(circleOfRadius: megaRocket.size.width/2)
                megaRocket.physicsBody?.dynamic = true
                megaRocket.physicsBody?.categoryBitMask = PhysicsCategory.Rocket
                megaRocket.physicsBody?.contactTestBitMask = PhysicsCategory.UFO
                megaRocket.physicsBody?.collisionBitMask = PhysicsCategory.None
                megaRocket.physicsBody?.usesPreciseCollisionDetection = true
                
                addChild(megaRocket)
                
                let direction = CGPoint(x: 0, y: 1)
                
                let shootAmount = direction * (self.size.height + 100)
                
                let realDest = shootAmount + megaRocket.position
                
                let actionMove = SKAction.moveTo(realDest, duration: 12.0)
                let actionAccel = SKAction.speedBy(50, duration: 12.0)
                let actionMoveDone = SKAction.runBlock() {
                    megaRocket.removeFromParent()
                }
                megaRocket.runAction(SKAction.sequence([SKAction.group([actionMove,actionAccel]), actionMoveDone]))
            }
        } else {
            for child in self.children {
                if (child.name == "Again_Button") {
                    if (child.containsPoint(touchLocation)) {
                        for otherChild in self.children {
                            if (otherChild.name == "ufo" || otherChild.name == "rocket" || otherChild.name == "megaRocket" || otherChild.name == "fallingBlockade" || otherChild.name == "fallingBomb" || otherChild.name == "fallingMegaRocket" || otherChild.name == "blockade" || otherChild.name == "fallingRocketRemaining" || otherChild.name == "timerBar") {
                                addExplosion(otherChild)
                                otherChild.removeFromParent()
                            }
                        }
                        
                        child.hidden = true
                        gameOver = false
                        for var i = rocketsRemaining; i < maxRockets; i++ {
                            addRocketRemaining()
                        }
                        score = 0
                        timeStamp = 0
                        scoreMessage = "Score: \(score)"
                        scoreLabel.text = scoreMessage
                        loseLabel.hidden = true
                        for otherChild in self.children {
                            if (otherChild.name == "High_Score_Label") {
                                otherChild.removeFromParent()
                            }
                        }
                        shootMegaRocket = false
                        NSNotificationCenter.defaultCenter().postNotificationName("hideAd", object: nil)
                    }
                }
            }
        }
    }
    
    func projectileDidCollideWithUFO(ufo:SKSpriteNode, rocket:SKSpriteNode) {
        
        if (ufo.name == "ufo") {
            if (rocket.name == "megaRocket") {
                addExplosion(ufo)
                
                ufo.removeFromParent()
                score++
            } else {
                addExplosion(ufo)
                
                rocket.removeFromParent()
                ufo.removeFromParent()
                score++
                addRocketRemaining()
            }
        } else if (ufo.name == "fallingBlockade") {
            addExplosion(ufo)
            addBlockade(ufo.position)
            ufo.removeFromParent()
            rocket.removeFromParent()
            addRocketRemaining()
        } else if (ufo.name == "fallingBomb") {
            addExplosion(ufo)
            rocket.removeFromParent()
            for child in self.children {
                if (child.name == "ufo") {
                    score++
                    addExplosion(child)
                    child.removeFromParent()
                } else if (child.name == "rocket") {
                    addExplosion(child)
                    child.removeFromParent()
                }
            }
            ufo.removeFromParent()
            addRocketRemaining()
        } else if (ufo.name == "fallingRocketRemaining") {
            addExplosion(ufo)
            addRocketRemaining()
            ufo.removeFromParent()
            rocket.removeFromParent()
            addRocketRemaining()
        } else if (ufo.name == "fallingMegaRocket") {
            addExplosion(ufo)
            shootMegaRocket = true
            ufo.removeFromParent()
            rocket.removeFromParent()
            addRocketRemaining()
            
            let timerBar = SKSpriteNode(imageNamed: "Timer_Bar")
            timerBar.position = CGPoint(x: self.size.width - timerBar.size.width/2, y: timerBar.size.height/2)
            timerBar.zPosition = 2.0
            timerBar.name = "timerBar"
            addChild(timerBar)
            timerBar.runAction(SKAction.moveToX(-timerBar.size.width/2, duration: 6))
            
            let waiting = SKAction.waitForDuration(NSTimeInterval(6))
            let endPowerUp = SKAction.runBlock() {
                self.shootMegaRocket = false
                timerBar.removeFromParent()
            }
            
            self.runAction(SKAction.sequence([waiting, endPowerUp]))
        }
    }
    
    func addExplosion(node: SKNode) {
        let sksPath = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")
        let explosionEmmiter: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(sksPath!) as! SKEmitterNode
        explosionEmmiter.position = node.position
        explosionEmmiter.name = "explosionEmmiter"
        explosionEmmiter.zPosition = 1.0
        if (node.name == "rocket") {
            explosionEmmiter.emissionAngle = CGFloat(M_PI + M_PI_2)
            explosionEmmiter.emissionAngleRange = 2.1817
            explosionEmmiter.particlePositionRange = CGVector(dx: 15, dy: 15)
        } else if (node.name == "blockade") {
            explosionEmmiter.emissionAngle = 0.0
            explosionEmmiter.emissionAngleRange = CGFloat(6.28)
            explosionEmmiter.particlePositionRange = CGVector(dx: 140, dy: 37.5)
        } else if (node.name == "fallingBlockade" || node.name == "fallingBomb" || node.name == "fallingRocketRemaining" || node.name == "fallingMegaRocket") {
            explosionEmmiter.emissionAngle = 0.0
            explosionEmmiter.emissionAngleRange = CGFloat(6.28)
            explosionEmmiter.particlePositionRange = CGVector(dx: 45, dy: 37.5)
        } else {
            explosionEmmiter.emissionAngle = CGFloat(M_PI_2)
            explosionEmmiter.emissionAngleRange = 2.1817
            explosionEmmiter.particlePositionRange = CGVector(dx: 15, dy: 15)
        }
        explosionEmmiter.targetNode = self
        
        self.addChild(explosionEmmiter)
        
        let waiting = SKAction.waitForDuration(NSTimeInterval(0.15))
        let stopEmmiting = SKAction.runBlock() {
            explosionEmmiter.particleBirthRate = 0.0
        }
        let waiting2 = SKAction.waitForDuration(1.5)
        let removal = SKAction.runBlock() {
            explosionEmmiter.removeFromParent()
        }
        
        explosionEmmiter.runAction(SKAction.sequence([waiting, stopEmmiting, waiting2, removal]))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        let isFirstInScene = firstBody.node?.inParentHierarchy(self)
        let isSecondInScene = secondBody.node?.inParentHierarchy(self)
        if (isFirstInScene != nil && isSecondInScene != nil) {
            let collision = (contact.bodyA.categoryBitMask & contact.bodyB.categoryBitMask)
            
            if (collision == (PhysicsCategory.UFO & PhysicsCategory.Rocket)) {
                var UFO:SKNode
                var Rocket:SKNode
                
                if (contact.bodyA.categoryBitMask == PhysicsCategory.UFO && contact.bodyB.categoryBitMask == PhysicsCategory.Rocket)
                {
                    UFO = contact.bodyA.node!
                    Rocket = contact.bodyB.node!
                    
                    projectileDidCollideWithUFO(UFO as! SKSpriteNode, rocket:Rocket as! SKSpriteNode)
                    
                } else if (contact.bodyB.categoryBitMask == PhysicsCategory.UFO && contact.bodyA.categoryBitMask == PhysicsCategory.Rocket){
                    UFO = contact.bodyB.node!
                    Rocket = contact.bodyA.node!
                    
                    projectileDidCollideWithUFO(UFO as! SKSpriteNode, rocket:Rocket as! SKSpriteNode)

                }
            } else if (collision == (PhysicsCategory.UFO & PhysicsCategory.Blockade)) {
                var UFO:SKNode
                var Blockade:SKNode
                
                if (contact.bodyA.categoryBitMask == PhysicsCategory.UFO && contact.bodyB.categoryBitMask == PhysicsCategory.Blockade)
                {
                    UFO = contact.bodyA.node!
                    Blockade = contact.bodyB.node!
                    
                    addExplosion(UFO)
                    UFO.removeFromParent()
                    score++
                    
                } else if (contact.bodyB.categoryBitMask == PhysicsCategory.UFO && contact.bodyA.categoryBitMask == PhysicsCategory.Blockade) {
                    UFO = contact.bodyB.node!
                    Blockade = contact.bodyA.node!
                    
                    addExplosion(UFO)
                    UFO.removeFromParent()
                    score++
                
                }
            } else if (collision == (PhysicsCategory.Rocket & PhysicsCategory.Blockade)) {
                var Rocket:SKNode
                var Blockade:SKNode
                
                if (contact.bodyA.categoryBitMask == PhysicsCategory.Rocket && contact.bodyB.categoryBitMask == PhysicsCategory.Blockade) {
                    Rocket = contact.bodyA.node!
                    Blockade = contact.bodyB.node!
                    
                    addExplosion(Rocket)
                    Rocket.removeFromParent()
                    
                } else if (contact.bodyB.categoryBitMask == PhysicsCategory.Rocket && contact.bodyA.categoryBitMask == PhysicsCategory.Blockade) {
                    Rocket = contact.bodyB.node!
                    Blockade = contact.bodyA.node!
                    
                    addExplosion(Rocket)
                    Rocket.removeFromParent()
                    
                }
            }
        } else {
            //println("Rejected a collision of a zombie object")
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (gameOver) {
            loseLabel.hidden = false
        } else {
            scoreMessage = "Score: \(score)"
        }
        
        scoreLabel.text = scoreMessage
        
        timeStamp++
        powerUpTimeStamp++
        
        if (timeStamp % 5 == 0) {
            addStar()
        }
        
        var spawnRate = Int(45 - 0.125 * Float(score))
        if (spawnRate < 30) {
            spawnRate = 30
        }
        
        //println(spawnRate)
        
        var diff = 0.012 * Float(score)
        if (diff >= 1.5) {
            diff = 1.48
        }
        
        if (timeStamp > spawnRate) {
            addUFO(diff)
            timeStamp = 0
        }
        
        if (timeStamp % spawnRate == 0) {
            addUFO(diff)
            timeStamp = 0
        }
        
        let randomization = random(min: 0, max: 100)
        if (powerUpTimeStamp % (10*60) == 0) {
            if (addRocketPowerUp && !shootMegaRocket) {
                if (randomization < 25) {
                    addFallingBlockade()
                } else if (randomization < 50) {
                    addFallingBomb()
                } else if (randomization < 75) {
                    addFallingMegaRocket()
                } else {
                    addRocketRemainingPowerUp()
                }
            } else if (!addRocketPowerUp && shootMegaRocket) {
                if (randomization < 50) {
                    addFallingBlockade()
                } else {
                    addFallingBomb()
                }
            } else if (addRocketPowerUp && shootMegaRocket) {
                if (randomization < 33) {
                    addFallingBlockade()
                } else if (randomization < 67) {
                    addFallingBomb()
                } else {
                    addRocketRemainingPowerUp()
                }
            } else {
                if (randomization < 33) {
                    addFallingBlockade()
                } else if (randomization < 67) {
                    addFallingBomb()
                } else {
                    addFallingMegaRocket()
                }
            }
            powerUpTimeStamp = 0
        }
        
        if (rocketsRemaining < 3) {
            addRocketPowerUpTimer++
        } else {
            addRocketPowerUpTimer = 1
            addRocketPowerUp = false
        }
        
        if (addRocketPowerUpTimer % 300 == 0) {
            addRocketPowerUp = true
        }
    }
    
    func printHighScores(scores: HighScoreManager) {
        for _ in scores.scores {
            //println(i.score)
        }
    }
}
