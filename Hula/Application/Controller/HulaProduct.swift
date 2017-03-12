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
    var arrProductPhotoLink: Array<String>!
    var productDescription: String!
    
    class var sharedInstance: HulaProduct {
        struct Static {
            static let instance: HulaProduct = HulaProduct()
        }
        return Static.instance
    }
    
    func initVal() {
        self.productId = -1
        self.productName = ""
        self.productDescription = ""
    }
}
