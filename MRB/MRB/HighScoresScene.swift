//
//  HighScoresGameScene.swift
//  MRB
//
//  Created by Ethan Look on 12/26/14.
//  Copyright (c) 2014 Ethan Look. All rights reserved.
//

import Foundation
import SpriteKit

class HighScoresScene: SKScene {
    
    var timeStamp: Int
    
    var invaderHighScores:HighScoreManager
    var highScoresLabel: SKNode
    var scoreOne: SKLabelNode
    var scoreTwo: SKLabelNode
    var scoreThree: SKLabelNode
    var menuMessage:String
    var menuLabel:SKLabelNode
    var titleMessage:String
    var titleLabel:SKLabelNode
    var topBar:SKSpriteNode
    
    override init(size: CGSize) {
        timeStamp = 0
        
        let invaderGameScene = InvaderGameScene(size: size)
        invaderHighScores = invaderGameScene.invaderHighScores
        
        highScoresLabel = SKNode()
        scoreOne = SKLabelNode(fontNamed: "Futura-Medium")
        scoreTwo = SKLabelNode(fontNamed: "Futura-Medium")
        scoreThree = SKLabelNode(fontNamed: "Futura-Medium")

        menuMessage = "HOME"
        menuLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        titleMessage = "HIGH SCORES"
        titleLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        topBar = SKSpriteNode (imageNamed: "Top_Bar")
        
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("showAd", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("addInterstitialAd", object: nil)
        
        backgroundColor = SKColor.blackColor()
        
        addStars(150)
        
        topBar.zPosition = 2.0
        topBar.position = CGPointMake(self.size.width/2, self.size.height - topBar.size.height/2)
        topBar.name = "topBar"
        
        menuLabel.text = menuMessage
        menuLabel.fontSize = 18
        menuLabel.fontColor = SKColor.yellowColor()
        menuLabel.position = CGPoint(x: size.width - (topBar.frame.height - menuLabel.frame.height)/2 - menuLabel.frame.width/2, y: self.size.height - topBar.frame.height/2  - menuLabel.frame.height/2)
        menuLabel.zPosition = 3.0
        menuLabel.name = "menu"
        self.addChild(self.menuLabel)
        
        titleLabel.text = titleMessage
        titleLabel.fontSize = 36
        titleLabel.fontColor = SKColor.yellowColor()
        titleLabel.position = CGPoint(x: size.width/2, y: self.size.height/2 + 120 - titleLabel.frame.height/2)
        titleLabel.zPosition = 3.0
        titleLabel.name = "title"
        addChild(titleLabel)
        
        printHighScores(invaderHighScores)
        
        var topScores = getTopHighScores(invaderHighScores)
        
        if (topScores.count != 0) {
            for index in 0...(topScores.count - 1) {
                if (index == 0) {
                    scoreOne.text = "\((index + 1)). \(topScores[index])"
                    scoreOne.fontSize = 32
                    scoreOne.fontColor = SKColor.yellowColor()
                    scoreOne.zPosition = 3.0
                    scoreOne.name = "scoreOne"
                    highScoresLabel.addChild(scoreOne)
                } else if (index == 1) {
                    scoreTwo.text = "\((index + 1)). \(topScores[index])"
                    scoreTwo.fontSize = 32
                    scoreTwo.fontColor = SKColor.yellowColor()
                    scoreTwo.position = CGPoint(x: scoreTwo.position.x, y: scoreTwo.position.y - 60)
                    scoreTwo.zPosition = 3.0
                    scoreTwo.name = "scoreTwo"
                    highScoresLabel.addChild(scoreTwo)
                } else {
                    scoreThree.text = "\((index + 1)). \(topScores[index])"
                    scoreThree.fontSize = 32
                    scoreThree.fontColor = SKColor.yellowColor()
                    scoreThree.position = CGPoint(x: scoreThree.position.x, y: scoreThree.position.y - 120)
                    scoreThree.zPosition = 3.0
                    scoreThree.name = "scoreThree"
                    highScoresLabel.addChild(scoreThree)
                }
            }
        }
        
        if (topScores.count == 0) {
            let noScore = SKLabelNode(fontNamed: "Futura-Medium")
            noScore.text = "NO HIGH SCORES"
            noScore.fontSize = 32
            noScore.fontColor = SKColor.yellowColor()
            noScore.zPosition = 3.0
            noScore.name = "noScore"
            highScoresLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            highScoresLabel.addChild(noScore)
        } else if (topScores.count == 1) {
            highScoresLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - 40)
        } else if (topScores.count == 2) {
            highScoresLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - 10)
        } else {
            highScoresLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 20)
        }
        addChild(highScoresLabel)
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
    
    func getTopHighScores(scores: HighScoreManager) -> [Int] {
        var retval: [Int]
        //println(invaderHighScores.scores.count)
        if (invaderHighScores.scores.count == 0) {
            retval = []
        } else if (invaderHighScores.scores.count == 1) {
            retval = [0]
            for i in scores.scores {
                if (i.score > retval[0]) {
                    retval[0] = i.score
                }
            }
        } else if (invaderHighScores.scores.count == 2) {
            retval = [0,0]
            for i in scores.scores {
                if (i.score > retval[0]) {
                    retval[1] = retval[0]
                    retval[0] = i.score
                } else if (i.score > retval[1]) {
                    retval[1] = i.score
                }
            }
        } else {
            retval = [0,0,0]
            for i in scores.scores {
                if (i.score > retval[0]) {
                    retval[2] = retval[1]
                    retval[1] = retval[0]
                    retval[0] = i.score
                } else if (i.score > retval[1]) {
                    retval[2] = retval[1]
                    retval[1] = i.score
                } else if (i.score > retval[2]) {
                    retval[2] = i.score
                }
            }
        }
        
        return retval
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        for child in self.children {
            if (child.name == "menu") {
                if (child.containsPoint(touchLocation)) {
                    let menuScene = MenuScene(size: self.size)
                    self.view?.presentScene(menuScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: 1.75))                }
            }
        }
    }
    
    func printHighScores(scores: HighScoreManager) {
        for i in scores.scores {
            print(i.score)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        timeStamp++
        
        if (timeStamp % 5 == 0) {
            addStar()
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}