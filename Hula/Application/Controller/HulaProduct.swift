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
    var productStatus: String!
    var tradeStatus: Int = 0
    var productOwner: String!
    var productCategoryId: String!
    var productLocation: CLLocation!
    var video_requested : [String:Bool]!
    var video_url: [String:String]!
    var trading_count: Int!
    var distance: Double {
        get {
            return productLocation.distance(from: HulaUser.sharedInstance.location)
        }
    }

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
        self.productStatus = ""
        self.productOwner = ""
        self.video_url = [:]
        self.video_requested = [:]
        self.productLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        self.trading_count = 0
    }
    init(id : String, name : String, image: String) {
        self.productId = id
        self.productName = name
        self.productDescription = ""
        self.productCondition = ""
        self.productCategory = ""
        self.productCategoryId = ""
        self.productStatus = ""
        self.productImage = image
        self.arrProductPhotos = NSMutableArray.init()
        self.arrProductPhotoLink = []
        self.tradeStatus = 0
        self.productOwner = ""
        self.video_url = [:]
        self.video_requested = [:]
        self.productLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        self.trading_count = 0
    }
    override var description : String {
        return "(Product id: \(self.productId!); name:   \(self.productName!); dist:   \(self.distance))\n"
    }

    func populate(with: NSDictionary){
        if let tmp = with.object(forKey: "_id") as? String { productId = tmp }
        if let tmp = with.object(forKey: "title") as? String { productName = tmp }
        if let tmp = with.object(forKey: "description") as? String { productDescription = tmp }
        if let tmp = with.object(forKey: "condition") as? String { productCondition = tmp }
        if let tmp = with.object(forKey: "category_name") as? String { productCategory = tmp }
        if let tmp = with.object(forKey: "category_id") as? String { productCategoryId = tmp }
        if let tmp = with.object(forKey: "image_url") as? String { productImage = tmp }
        if let tmp = with.object(forKey: "status") as? String { productStatus = tmp }
        if let tmp = with.object(forKey: "owner_id") as? String { productOwner = tmp }
        if let tmp = with.object(forKey: "video_requested") as? [String:Bool] { video_requested = tmp }
        if let tmp = with.object(forKey: "video_url") as? [String:String] { video_url = tmp }
        if let tmp = with.object(forKey: "trading_count") as? Int { trading_count = tmp }
        if let tmp = with.object(forKey: "images") as? [String] {
            arrProductPhotoLink = []
            for im in tmp {
                if im.count > 0 {
                    arrProductPhotoLink.append(im)
                }
            }
        }
        print (with.object(forKey: "location") as? [Any])
        if let tmp = with.object(forKey: "location") as? [Any] {
            let lat = tmp[0] as? Double
            let lon = tmp[1] as? Double
            print(Float(lat!))

            if (lat != nil && lon != nil){
                productLocation = CLLocation(latitude: CLLocationDegrees(Float(lat!)), longitude: CLLocationDegrees(Float(lon!)))
            }

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
                    //print(json!)
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
            "&condition=" + self.productCondition
        str = str + "&category_name=" + self.productCategory +
            "&category_id=" + self.productCategoryId +
            "&image_url=" + self.productImage
        str = str + "&owner_id=" + self.productOwner +
            "&images=" + self.arrProductPhotoLink.joined(separator: ",")
        /*
        if (self.productLocation.coordinate.latitude != 0 && self.productLocation.coordinate.longitude != 0){
            str = str + "&lat=\(self.productLocation.coordinate.latitude)&lng=\(self.productLocation.coordinate.longitude)"
        }
        */
        str += "&lat=\(HulaUser.sharedInstance.location.coordinate.latitude)"
        str += "&lng=\(HulaUser.sharedInstance.location.coordinate.longitude)"
        print(str)
        return str
    }
}

/// Pins in-flight create POST/upload callbacks to the listing that started them.
/// `HLDataManager.newProduct` is a singleton; replacing it while create is in flight
/// must not retarget `product_id` or photo URLs onto a different object.
struct ProductCreateSession {
    static func firstLocalPhoto(on product: HulaProduct) -> UIImage? {
        if product.arrProductPhotos.count > 0 {
            return product.arrProductPhotos.object(at: 0) as? UIImage
        }
        return nil
    }

    static func shouldPresentCompleteProfile(captured: HulaProduct, current: HulaProduct) -> Bool {
        return captured === current
    }

    static func applyCreatedProductId(_ productId: String, to product: HulaProduct) {
        if productId.count > 0 {
            product.productId = productId
        }
    }

    static func preparedPhotoSlots() -> [String] {
        return ["", "", "", ""]
    }

    /// Writes a photo URL onto `product` (not whatever `newProduct` currently is).
    /// Returns false if `position` is out of range for the 4-slot create array.
    static func applyPhotoLink(_ url: String, at position: Int, to product: HulaProduct) -> Bool {
        var links = product.arrProductPhotoLink
        while links.count < 4 {
            links.append("")
        }
        if position < 0 || position >= links.count {
            return false
        }
        links[position] = url
        product.arrProductPhotoLink = links
        if position == 0 {
            product.productImage = url
        }
        return true
    }
}

class ProductCreateUploadProgress {
    var toUpload: Int = 0
    var uploaded: Int = 0
}
