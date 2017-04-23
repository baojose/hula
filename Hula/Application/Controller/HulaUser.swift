//
//  HulaUser.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaUser: NSObject {
    
    var userId: String!
    var userName: String!
    var userNick: String!
    var userEmail: String!
    var userPhotoURL: String!
    var userLocationName: String!
    var userBio: String!
    var token: String!
    var location: CGPoint!
    
    class var sharedInstance: HulaUser {
        struct Static {
            static let instance: HulaUser = HulaUser()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.userId = ""
        self.userNick = ""
        self.userName = ""
        self.userEmail = ""
        self.userPhotoURL = ""
        self.userLocationName = ""
        self.userBio = ""
        self.token = ""
        self.location = CGPoint(x:0, y:0)
    }
    

}
