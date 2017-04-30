//
//  HulaProduct.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaProduct: NSObject {
    
    var productId: Int!
    var productName: String!
    var productCategory: String!
    var productCondition: String!
    var arrProductPhotoLink: NSMutableArray!
    var arrProductPhotos: NSMutableArray!
    var productDescription: String!
    
    class var sharedInstance: HulaProduct {
        struct Static {
            static let instance: HulaProduct = HulaProduct()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.productId = -1
        self.productName = ""
        self.productDescription = ""
        self.productCondition = ""
        self.productCategory = ""
        self.arrProductPhotos = NSMutableArray.init()
        self.arrProductPhotoLink = NSMutableArray.init()
    }
}
