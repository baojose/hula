//
//  HulaVideoTransp.swift
//  Hula
//
//  Created by Juan Searle FC on 25/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import SpriteKit

class HulaVideoTransp: SKScene {
    var textureName:String = "slide_1_2.atlas"
    var textureAtlas:SKTextureAtlas!
    var currentTexture:Int = 1;
    var slide1Frames = [SKTexture]()
    var sprite:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFit
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0);
        //print("loading texture...")
        
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
        
        
    }
    
    init(size:CGSize, textureName: String){
        super.init(size:size)
        self.textureName = textureName
        self.textureAtlas = SKTextureAtlas(named: self.textureName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func play() {
        //This is our general runAction method to make our bear walk.
        SKTextureAtlas.preloadTextureAtlases([textureAtlas]) { 
            let when = DispatchTime.now() + 1.0
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.sprite.run(SKAction.repeat(
                    SKAction.animate(with: self.slide1Frames,
                                     timePerFrame: 1/25,
                                     resize: false,
                                     restore: true), count: 1),
                                withKey:"playing")
                
            }
        }
        

        
    }
    
    func stop() {
        //This is our general runAction method to make our bear walk.
        if (sprite != nil){
            if let action = sprite.action(forKey: "playing"){
                action.speed = 0
            }
        }
    }
}
