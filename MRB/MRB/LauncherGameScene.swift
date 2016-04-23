//
//  LauncherGameScene.swift
//  MRB
//
//  Created by Ethan Look on 1/17/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import SpriteKit

class LauncherGameScene: SKScene {

    var starCount: Int
    var timeStamp: Int
    var menuMessage:String
    var menuLabel:SKLabelNode
    var topBar:SKSpriteNode
    
    override init(size: CGSize) {
        timeStamp = 0
        
        starCount = 150
        
        menuMessage = "HOME"
        menuLabel = SKLabelNode(fontNamed: "Futura-Medium")
        topBar = SKSpriteNode(imageNamed: "Top_Bar")
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("hideAd", object: nil)
        
        backgroundColor = SKColor.blackColor()
        
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
        
        addStars(starCount)
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        for child in self.children {
            if (child.name == "menu") {
                if (child.containsPoint(touchLocation)) {
                    let menuScene = MenuScene(size: self.size)
                    self.view?.presentScene(menuScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 1.75))
                }
            }
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
    
}