//
//  HulaUser.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaUser: NSObject {
    
    var userId: Int!
    var userName: String!
    var userEmail: String!
    var userPhotoLink: String!
    var userLocationName: String!
    
    class var sharedInstance: HulaUser {
        struct Static {
            static let instance: HulaUser = HulaUser()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.userId = -1
        self.userName = ""
        self.userEmail = ""
        self.userPhotoLink = ""
        self.userLocationName = ""
    }
}
