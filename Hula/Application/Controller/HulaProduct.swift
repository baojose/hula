//
//  HulaProduct.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaProduct: NSObject {
    
    var productId: String!
    var productName: String!
    var productCategory: String!
    var productCondition: String!
    var arrProductPhotoLink: [String]!
    var arrProductPhotos: NSMutableArray!
    var productDescription: String!
    var productImage: String!
    var tradeStatus: Int = 0
    
    class var sharedInstance: HulaProduct {
        struct Static {
            static let instance: HulaProduct = HulaProduct()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.productId = ""
        self.productName = ""
        self.productDescription = ""
        self.productCondition = ""
        self.productCategory = ""
        self.productImage = ""
        self.arrProductPhotos = NSMutableArray.init()
        self.arrProductPhotoLink = []
        self.tradeStatus = 0
    }
    init(id : String, name : String, image: String) {
        self.productId = id
        self.productName = name
        self.productDescription = ""
        self.productCondition = ""
        self.productCategory = ""
        self.productImage = image
        self.arrProductPhotos = NSMutableArray.init()
        self.arrProductPhotoLink = []
        self.tradeStatus = 0
    }
}
