//
//  MenuRocket.swift
//  MRB
//
//  Created by Ethan Look on 1/16/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import Foundation
import SpriteKit

class MenuRocket: Sprite {
    
    var rocketX: CGFloat!
    var sceneSize: CGSize!
    
    init(sceneSize: CGSize) {
        let texture = SKTexture(imageNamed: "rocket")
        self.sceneSize = sceneSize
        rocketX = random(min: CGFloat(0.0), max: sceneSize.width)
        super.init(imageNamed: "rocket", name: "rocket", x: rocketX, y: -texture.size().height/2, zPosition: 0.0)
        fly()
    }
    
    func fly() {
        let actualDuration = random(min: CGFloat(10), max: CGFloat(12))
        
        let actionMove = SKAction.moveToY(self.sceneSize.height + sprite.size.width/2, duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock() {
            self.sprite.removeFromParent()
        }
        self.sprite.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

