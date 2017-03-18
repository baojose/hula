//
//  HLDataManager.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLDataManager: NSObject {
    
    var currentUser: HulaUser!
    var newProduct: HulaProduct!
    var arrCategories : NSMutableArray!
    var uploadMode: Bool!
    
    class var sharedInstance: HLDataManager {
        struct Static {
            static let instance: HLDataManager = HLDataManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        uploadMode = false
        currentUser = HulaUser.init()
        newProduct = HulaProduct.init()
        arrCategories = [["icon" : "icon_cat_service" , "name" : "SERVICES"],
                         ["icon" : "icon_cat_cars" , "name" : "CARS, BIKES & AUTO PARTS"],
                         ["icon" : "icon_cat_clothing" , "name" : "CLOTHING"],
                         ["icon" : "icon_cat_electronic" , "name" : "ELECTRONICS & MOBILE"],
                         ["icon" : "icon_cat_furniture" , "name" : "FURNITURE"],
                         ["icon" : "icon_cat_art" , "name" : "ART & ANTIQUES"],
                         ["icon" : "icon_cat_house" , "name" : "HOUSE, YARD & FURNITURE"],
                         ["icon" : "icon_cat_videogames" , "name" : "VIDEOGAMES"],
                         ["icon" : "icon_cat_collectible" , "name" : "COLLECTIBLE & HOBBBIES"],
                         ["icon" : "icon_cat_music" , "name" : "MUSIC & MUSICAL INSTRUMENTS"],
                         ["icon" : "icon_cat_tool" , "name" : "TOOLS & REPAIR"],
                         ["icon" : "icon_cat_photography" , "name" : "PHOTOGRAPHY"],
                         ["icon" : "icon_cat_computer" , "name" : "COMPUTERS"],
                         ["icon" : "icon_cat_sport" , "name" : "SPORTS"],
                         ["icon" : "icon_cat_jewelry" , "name" : "JEWELRY"],
                         ["icon" : "icon_cat_camping" , "name" : "CAMPING, SURVIVAL & OUTDOORS"],
                         ["icon" : "icon_cat_other" , "name" : "OTHERS"]]
    }
}
