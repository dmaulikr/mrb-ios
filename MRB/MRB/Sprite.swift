//
//  Sprite.swift
//  MRB
//
//  Created by Ethan Look on 1/16/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import SpriteKit

class Sprite {
    let sprite = SKSpriteNode()
    
    init(imageNamed:String, name:String, x:CGFloat, y:CGFloat, zPosition: CGFloat) {
        sprite.texture = SKTexture(imageNamed: imageNamed)
        sprite.position = CGPoint(x: x, y: y)
        sprite.size = sprite.texture!.size()
        sprite.name = name
        sprite.zPosition = zPosition
    }
    
    convenience init(imageNamed:String, x:CGFloat, y:CGFloat, zPosition: CGFloat) {
        self.init(imageNamed: imageNamed, name: "sprite", x: x, y: y, zPosition: zPosition)
    }
    
    func addTo(parentNode: MenuScene) -> Sprite {
        parentNode.addChild(sprite)
        return self
    }
}
