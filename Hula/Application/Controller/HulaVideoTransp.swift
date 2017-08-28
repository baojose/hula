//
//  HulaVideoTransp.swift
//  Hula
//
//  Created by Juan Searle FC on 25/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import SpriteKit

class HulaVideoTransp: SKScene {
    let textureAtlas = SKTextureAtlas(named:"slide_1_2.atlas")
    var currentTexture:Int = 1;
    var slide1Frames = [SKTexture]()
    var sprite:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0);
        
        
        let numImages = textureAtlas.textureNames.count
        for i in 0 ..< numImages {
            let n = String(format: "%03d", i)
            let tx = "slide\(n)"
            slide1Frames.append(textureAtlas.textureNamed(tx))
        }
        
        
        let firstFrame = slide1Frames[0]
        sprite = SKSpriteNode(texture: firstFrame)
        sprite.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        //sprite.scale(to: CGSize(width: self.frame.width, height: self.frame.height))
        sprite.size = CGSize(width: self.frame.width, height: self.frame.height)
        addChild(sprite)
        play()
    }
    
    func play() {
        //This is our general runAction method to make our bear walk.
        sprite.run(SKAction.repeat(
            SKAction.animate(with: slide1Frames,
                 timePerFrame: 1/30,
                 resize: false,
                 restore: true), count: 4),
            withKey:"playing")
    }
}
