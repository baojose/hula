//
//  HLSpinnerUIView.swift
//  Hula
//
//  Created by Juan Searle on 29/7/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSpinnerUIView: UIView {
    
    var spinning: Bool = false
    
    
    
    func show(inView: UIView) {
        let spinner = UIView();
        spinner.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
        spinner.center = inView.center
        
        let img = UIImage(named: "added-arrow")
        let image = UIImageView(image: img)
        
        spinner.addSubview(image)
        
        self.addSubview(spinner)
        
        spinning = true
        rotate(targetView: image, duration: 0.5)
    }
    
    func hide(){
        for subUIView in self.subviews as [UIView] {
            subUIView.removeFromSuperview()
        }
        spinning = false
    }
    
    private func rotate(targetView: UIView, duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(M_PI))
        }) { finished in
            self.rotate(targetView: targetView, duration: duration)
        }
    }
}
