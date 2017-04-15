//
//  HLRoundedNextButton.swift
//  Hula
//
//  Created by Juan Searle on 16/04/2017.
//  Copyright © 2017 star. All rights reserved.
//


import UIKit

class HLRoundedNextButton: UIButton {
    
    let arrowLayer:CALayer = CALayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4).cgColor
        
        
        self.layer.cornerRadius = rect.height/2
        self.layer.backgroundColor = color
        
        
        
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
    }
    
    public func setup(){
        let arrow_width:CGFloat = 10
        let arrow_height:CGFloat = 16
        let padding:CGFloat = 12
        let rect = self.bounds
        
        let arrowImage = UIImage(named: "icon_forward_white")?.cgImage
        arrowLayer.frame = CGRect(x: rect.origin.x + rect.width - arrow_width - padding, y:rect.origin.y+padding, width: arrow_width, height:arrow_height)
        arrowLayer.contents = arrowImage
        self.layer.addSublayer(arrowLayer)
        
        
        
      
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.fromValue = [arrowLayer.frame.origin.x, rect.height/2]
        positionAnimation.toValue = [arrowLayer.frame.origin.x+padding, rect.height/2]
        positionAnimation.duration = 0.5
        positionAnimation.autoreverses = true
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.repeatCount = 1000
        
        // Finally, add the animation to the layer
        arrowLayer.add(positionAnimation, forKey: "position")
        
    }
}
