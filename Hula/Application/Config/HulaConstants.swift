//
//  HulaConstants.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import Foundation

struct HulaConstants {
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let appMainColor = UIColor(red: 57.0/255, green: 170.0/255, blue: 164.0/255, alpha: 1.0)
    
    static let product_max_size = 800.0
    static let product_image_thumb_size:CGSize = CGSize(width: product_max_size, height: product_max_size)
    
    // Server API Links
    static let apiURL: String = "https://api.hula.trading/v1/"
    static let staticServerURL: String = "https://hula.trading"
    static let noProductThumb: String = "https://hula.trading/files/user/nope.jpg"
    
    
    // local storage
    static let userFile: String = "UserData"
}
