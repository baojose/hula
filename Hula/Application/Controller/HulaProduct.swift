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
            return HulaProduct.debugDistance(
                productLocation: self.productLocation,
                userLocation: HulaUser.sharedInstance.location
            ) ?? 0
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
        return HulaProduct.debugDescriptionText(
            productId: self.productId,
            name: self.productName,
            distance: HulaProduct.debugDistance(
                productLocation: self.productLocation,
                userLocation: HulaUser.sharedInstance.location
            )
        )
    }

    /// Debug print used IUO unwraps of `productId!` / `productName!` / `distance`.
    class func debugDescriptionText(productId: String?, name: String?, distance: Double?) -> String {
        let id = productId ?? ""
        let nameText = name ?? ""
        let dist = distance ?? 0
        return "(Product id: \(id); name:   \(nameText); dist:   \(dist))\n"
    }

    class func debugDistance(productLocation: CLLocation?, userLocation: CLLocation?) -> Double? {
        guard let productLocation = productLocation, let userLocation = userLocation else {
            return nil
        }
        return productLocation.distance(from: userLocation)
    }

    /// Video-proof flags keyed by trade id. Nil maps / blank trade ids must not
    /// force-unwrap IUO dictionaries in barter cells or the product modal.
    class func isVideoRequested(_ map: [String:Bool]?, forTradeId tradeId: String?) -> Bool {
        guard let tradeId = CommonUtils.nonEmptyTrimmed(tradeId), let map = map else {
            return false
        }
        return map[tradeId] ?? false
    }

    class func videoURL(_ map: [String:String]?, forTradeId tradeId: String?) -> String {
        guard let tradeId = CommonUtils.nonEmptyTrimmed(tradeId), let map = map else {
            return ""
        }
        return map[tradeId] ?? ""
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
        if let tmp = CommonUtils.boolMapFromJSON(with.object(forKey: "video_requested")) {
            video_requested = tmp
        }
        if let tmp = CommonUtils.stringMapFromJSON(with.object(forKey: "video_url")) {
            video_url = tmp
        }
        if let count = CommonUtils.intFromJSON(with.object(forKey: "trading_count")) {
            trading_count = count
        }
        if let tmp = CommonUtils.stringArrayFromJSON(with.object(forKey: "images")) {
            arrProductPhotoLink = []
            for im in tmp {
                if im.count > 0 {
                    arrProductPhotoLink.append(im)
                }
            }
        }
        if let locationFromJSON = CommonUtils.location(fromJSON: with.object(forKey: "location")) {
            productLocation = locationFromJSON
        }
    }

    /// Product PUT. Blank productId must not hit `products/`.
    class func updateURL(apiBase: String, productId: String?) -> String? {
        return CommonUtils.productResourceURL(apiBase: apiBase, productId: productId)
    }
    
    func updateServerData(){
        //print("Updating user...")
        if(HulaUser.sharedInstance.isUserLoggedIn()){
            guard let queryURL = HulaProduct.updateURL(apiBase: HulaConstants.apiURL, productId: self.productId) else {
                return
            }
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
        var str = "title=" + CommonUtils.formEncodedValue(self.productName) +
            "&description=" + CommonUtils.formEncodedValue(self.productDescription) +
            "&condition=" + CommonUtils.formEncodedValue(self.productCondition)
        str = str + "&category_name=" + CommonUtils.formEncodedValue(self.productCategory) +
            "&category_id=" + CommonUtils.formEncodedValue(self.productCategoryId) +
            "&image_url=" + CommonUtils.formEncodedValue(self.productImage)
        str = str + "&owner_id=" + CommonUtils.formEncodedValue(self.productOwner) +
            "&images=" + CommonUtils.formEncodedValue(self.arrProductPhotoLink.joined(separator: ","))
        // Persist the product's own coordinates on edit. Using the user's live GPS
        // silently relocated listings whenever any field was updated.
        if let location = self.productLocation,
           location.coordinate.latitude != 0,
           location.coordinate.longitude != 0 {
            str = str + "&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)"
        }
        print(str)
        return str
    }

    /// Keep featured `image_url` aligned with the first photo; clear when the album is empty
    /// so a deleted last photo is not re-posted as the featured image.
    func syncFeaturedImageFromPhotos() {
        if let first = arrProductPhotoLink.first, first.count > 0 {
            productImage = first
        } else {
            productImage = ""
        }
    }

    /// Apply a uploaded image URL into a 1-based camera slot without corrupting earlier empties.
    func applyUploadedImage(path: String, pos: Int) {
        guard pos >= 1 else { return }
        let index = pos - 1
        while arrProductPhotoLink.count <= index {
            arrProductPhotoLink.append("")
        }
        arrProductPhotoLink[index] = path
        while let last = arrProductPhotoLink.last, last.isEmpty {
            arrProductPhotoLink.removeLast()
        }
        if pos == 1 {
            productImage = path
        } else if productImage.isEmpty, let first = arrProductPhotoLink.first, !first.isEmpty {
            productImage = first
        }
    }
}

/// Pins in-flight create POST/upload callbacks to the listing that started them.
/// `HLDataManager.newProduct` is a singleton; replacing it while create is in flight
/// must not retarget `product_id` or photo URLs onto a different object.
struct ProductCreateSession {
    static func firstLocalPhoto(on product: HulaProduct) -> UIImage? {
        return CommonUtils.uiImage(at: 0, in: product.arrProductPhotos)
    }

    /// Present Complete Profile only for the captured listing, and only if nothing else is already presented.
    static func shouldPresentCompleteProfile(captured: HulaProduct, current: HulaProduct, alreadyPresenting: Bool) -> Bool {
        if alreadyPresenting {
            return false
        }
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
        var links = product.arrProductPhotoLink ?? []
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

/// Per-create upload counters so two in-flight listings cannot mix slot URLs or PUT timing.
class ProductCreateUploadProgress {
    var toUpload: Int = 0
    var uploaded: Int = 0
}
