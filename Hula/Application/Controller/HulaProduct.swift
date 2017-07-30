//
//  HulaProduct.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MapKit

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
    var productOwner: String!
    var productCategoryId: String!
    var productLocation: CLLocation!
    
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
        self.productCategoryId = ""
        self.productImage = ""
        self.arrProductPhotos = NSMutableArray.init()
        self.arrProductPhotoLink = []
        self.tradeStatus = 0
        self.productOwner = ""
        self.productLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    }
    init(id : String, name : String, image: String) {
        self.productId = id
        self.productName = name
        self.productDescription = ""
        self.productCondition = ""
        self.productCategory = ""
        self.productCategoryId = ""
        self.productImage = image
        self.arrProductPhotos = NSMutableArray.init()
        self.arrProductPhotoLink = []
        self.tradeStatus = 0
        self.productOwner = ""
        self.productLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    }
    override var description : String {
        return "(Product id: \(self.productId!); name:   \(self.productName!))\n"
    }
    
    func populate(with: NSDictionary){
        if let tmp = with.object(forKey: "_id") as? String { productId = tmp }
        if let tmp = with.object(forKey: "title") as? String { productName = tmp }
        if let tmp = with.object(forKey: "description") as? String { productDescription = tmp }
        if let tmp = with.object(forKey: "condition") as? String { productCondition = tmp }
        if let tmp = with.object(forKey: "category_name") as? String { productCategory = tmp }
        if let tmp = with.object(forKey: "category_id") as? String { productCategoryId = tmp }
        if let tmp = with.object(forKey: "image_url") as? String { productImage = tmp }
        if let tmp = with.object(forKey: "owner_id") as? String { productOwner = tmp }
        if let tmp = with.object(forKey: "images") as? [String] {
            arrProductPhotoLink = []
            for im in tmp {
                if im.characters.count > 0 {
                    arrProductPhotoLink.append(im)
                }
            }
        }
        if let tmp = with.object(forKey: "location") as? [Float] {
            productLocation = CLLocation(latitude: CLLocationDegrees(tmp[0]), longitude: CLLocationDegrees(tmp[1]))
        }
    }
    
    func updateServerData(){
        //print("Updating user...")
        if(HulaUser.sharedInstance.isUserLoggedIn()){
            let queryURL = HulaConstants.apiURL + "products/" + self.productId
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: getPostString(), isPut: true, taskCallback: { (ok, json) in
                
                //print("done")
                //print(ok)
                if (ok){
                    print(json!)
                    if (json as? [String: Any]) != nil {
                        //print(dictionary)
                    }
                    
                    //NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
                }
            })
        }
    }
    func getPostString() -> String {
        var str = "title=" + self.productName +
            "&description=" + self.productDescription +
            "&condition=" + self.productCondition +
            "&category_name=" + self.productCategory +
            "&category_id=" + self.productCategoryId +
            "&image_url=" + self.productImage
        str = str + "&owner_id=" + self.productOwner +
            "&images=" + self.arrProductPhotoLink.joined(separator: ",")
        
        if (self.productLocation.coordinate.latitude != 0 && self.productLocation.coordinate.longitude != 0){
            str = str + "&lat=\(self.productLocation.coordinate.latitude)&lon=\(self.productLocation.coordinate.longitude)"
        }
        return str
    }
}
