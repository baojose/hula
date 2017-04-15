//
//  HLRoundedButton.swift
//  Hula
//
//  Created by Juan Searle on 15/4/17.
//  Copyright © 2017 Quoids. All rights reserved.
//

import UIKit


class HLRoundedButton: UIButton {

    override func draw(_ rect: CGRect) {
        // Drawing code
        let color = HulaConstants.appMainColor.cgColor

        
        self.layer.cornerRadius = rect.height/2
        self.layer.backgroundColor = color
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        
    }
    
}
