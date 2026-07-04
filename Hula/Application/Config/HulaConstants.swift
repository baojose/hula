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
    
    static let courtesyTime: Double = 72.0 // hours between trades
    
    // Server API Links
    static let apiURL: String = "https://api.hula.trading/v1/"
    static let staticServerURL: String = "https://hula.trading"
    static let noProductThumb: String = "https://hula.trading/files/user/nope_hula.jpg"
    static let transparentImg: String = "https://hula.trading/img/transparent_hula.png"
    
    // TRADE STATUSES
    static let pending_status:String = "pending"
    static let sent_status:String = "offer_sent"
    static let end_status:String = "ended"
    static let cancel_status:String = "closed"
    static let review_status:String = "review"
    
    
    // FONTS
    static let light_font:String = "HelveticaNeue-Light"
    static let regular_font:String = "HelveticaNeue-Medium"
    static let bold_font:String = "HelveticaNeue-Bold"
    
    // local storage
    static let userFile: String = "UserData"
    
    // Public snapshot: set in a local, non-committed override or restore from your secure store.
    // Obtain new credentials from Twitter Developer Portal — rotate if these ever leaked in git history.
    static let twitterKey: String = ""
    static let twitterSecret: String = ""

    // Public snapshot: set in a local, non-committed override or restore from your secure store.
    // Obtain new credentials from LinkedIn Developer Portal — rotate if these ever leaked in git history.
    static let linkedInClientId: String = ""
    static let linkedInClientSecret: String = ""
    static let linkedInState: String = ""
    static let linkedInPermissions: [String] = ["r_basicprofile", "r_emailaddress"]
    static let linkedInRedirectURL: String = "https://hula.trading/"
}
