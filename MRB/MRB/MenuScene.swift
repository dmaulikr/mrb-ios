//
//  MenuScene.swift
//  MRB
//
//  Created by Ethan Look on 12/17/14.
//  Copyright (c) 2014 Ethan Look. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

class MenuScene: SKScene {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    var timeStamp: Int
    
    var invaderModeMessage:String
    var invaderModeLabel:SKLabelNode
    var launcherModeMessage:String
    var launcherModeLabel:SKLabelNode
    var highScoresMessage:String
    var highScoresLabel:SKLabelNode
    var megaMessage:String
    var megaLabel:SKLabelNode
    var rocketMessage:String
    var rocketLabel:SKLabelNode
    var blasterMessage:String
    var blasterLabel:SKLabelNode
    var labelFormat:CGFloat
    
    var rockets:NSMutableSet
    
    override init(size: CGSize) {
        
        timeStamp = 0
        
        invaderModeMessage = "START INVASION"
        invaderModeLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        launcherModeMessage = "LAUNCH ROCKET"
        launcherModeLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        highScoresMessage = "HIGH SCORES"
        highScoresLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        megaMessage = "MEGA"
        megaLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        rocketMessage = "ROCKET"
        rocketLabel = SKLabelNode(fontNamed: "Futura-Medium")

        blasterMessage = "BLASTER"
        blasterLabel = SKLabelNode(fontNamed: "Futura-Medium")
        
        labelFormat = 120
        
        rockets = NSMutableSet()
        
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        
        view.showsPhysics = true
        
        NSNotificationCenter.defaultCenter().postNotificationName("showAd", object: nil)
        
        motionManager.startAccelerometerUpdates()
        
        backgroundColor = SKColor.blackColor()
        
        addStars(150)
        
        invaderModeLabel.text = invaderModeMessage
        invaderModeLabel.fontSize = 32
        invaderModeLabel.fontColor = SKColor.redColor()
        
        launcherModeLabel.text = launcherModeMessage
        launcherModeLabel.fontSize = 32
        launcherModeLabel.fontColor = SKColor.redColor()
        
        highScoresLabel.text = highScoresMessage
        highScoresLabel.fontSize = 32
        highScoresLabel.fontColor = SKColor.redColor()
        
        launcherModeLabel.position = CGPoint(x: size.width/2, y: size.height/2 - (labelFormat + launcherModeLabel.frame.height/2))
        launcherModeLabel.zPosition = 3.0
        launcherModeLabel.name = "launcherMode"
        //addChild(launcherModeLabel)
        
        invaderModeLabel.position = CGPoint(x: size.width/2, y: size.height/2 - (labelFormat - 12))
        invaderModeLabel.zPosition = 3.0
        invaderModeLabel.name = "invaderMode"
        addChild(invaderModeLabel)
        
        highScoresLabel.position = CGPoint(x: size.width/2, y: size.height/2 - (labelFormat + 12 + highScoresLabel.frame.height))
        highScoresLabel.zPosition = 3.0
        highScoresLabel.name = "highScores"
        addChild(highScoresLabel)
        
        megaLabel.text = megaMessage
        megaLabel.fontSize = 40
        megaLabel.fontColor = SKColor.yellowColor()
        
        rocketLabel.text = rocketMessage
        rocketLabel.fontSize = 60
        rocketLabel.fontColor = SKColor.yellowColor()
        
        blasterLabel.text = blasterMessage
        blasterLabel.fontSize = 40
        blasterLabel.fontColor = SKColor.yellowColor()
        
        rocketLabel.position = CGPoint(x: size.width/2, y: size.height/2 + (labelFormat - rocketLabel.frame.height/2))
        rocketLabel.zPosition = 3.0
        rocketLabel.name = "rocketLabel"
        addChild(rocketLabel)
        
        blasterLabel.position = CGPoint(x: size.width/2, y: size.height/2 + (labelFormat - rocketLabel.frame.height/2 - blasterLabel.frame.height - 7))
        blasterLabel.zPosition = 3.0
        blasterLabel.name = "blasterLabel"
        addChild(blasterLabel)
        
        megaLabel.position = CGPoint(x: size.width/2, y: size.height/2 + (labelFormat + rocketLabel.frame.height/2 + 7))
        megaLabel.zPosition = 3.0
        megaLabel.name = "megaLabel"
        addChild(megaLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        for child in self.children {
            if (child.name == "invaderMode") {
                if (child.containsPoint(touchLocation)) {
                    let invaderGameScene = InvaderGameScene(size: self.size)
                    self.view?.presentScene(invaderGameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 1.75))
                }
            }
            if (child.name == "launcherMode") {
                if (child.containsPoint(touchLocation)) {
                    let launcherGameScene = LauncherGameScene(size: self.size)
                    self.view?.presentScene(launcherGameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 1.75))
                }
            }
            if (child.name == "highScores") {
                if (child.containsPoint(touchLocation)) {
                    let highScoreScene = HighScoresScene(size: self.size)
                    self.view?.presentScene(highScoreScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1.75))
                }
            }
        }
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
    
    func addRocket() {
        let rocket = MenuRocket(sceneSize: self.size)
        rocket.addTo(self)
        rockets.addObject(rocket)
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        
        for rocket in rockets {
            let rocket = rocket as! MenuRocket
            if let data = motionManager.accelerometerData {
                if (data.acceleration.x > 0.2 && rocket.sprite.position.x > 0 && (rocket.rocketX - rocket.sprite.position.x) < 20) {
                    rocket.sprite.position.x -= 0.3
                } else if (data.acceleration.x < -0.2 && rocket.sprite.position.x < self.size.width && (rocket.sprite.position.x - rocket.rocketX) < 20) {
                    rocket.sprite.position.x += 0.3
                }
            }
        }
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        //processUserMotionForUpdate(currentTime)
        
        timeStamp++
        
        if (timeStamp % 5 == 0) {
            addStar()
        }
        
        if (timeStamp % 45 == 0) {
            addRocket()
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}