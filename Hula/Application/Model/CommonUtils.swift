//
//  CommonUtils.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import EasyTipView
import Kingfisher
import AVKit
import AVFoundation

class CommonUtils: NSObject, EasyTipViewDelegate, UIGestureRecognizerDelegate {
    
    var currentTipArr: [HulaTip] = []
    var currentTip:Int = -1
    var lastTip:EasyTipView = EasyTipView(text: "");
    var startingViewController: UIViewController!
    var bgViewToRemove : UIView!
    var tutorialToComplete : String = ""
    
    class var sharedInstance: CommonUtils {
        struct Static {
            static let instance: CommonUtils = CommonUtils()
        }
        return Static.instance
    }
    // Common Utils Functions
    func attributedStringWithTextSpacing(_ str: String, _ textSpacing: CGFloat) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: textSpacing, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    /// Page titles used `label.text!`. Nil outlet text must space an empty string.
    func attributedStringWithTextSpacing(_ str: String?, _ textSpacing: CGFloat) -> NSMutableAttributedString {
        return attributedStringWithTextSpacing(str ?? "", textSpacing)
    }
    func circleImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0;
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
    }
    func setRoundedRectBorderImageView(_ imageView: UIImageView, _ width: CGFloat, _ borderColor: UIColor, _ radius: CGFloat){
        let borderLayer: CALayer! = CALayer()
        let borderFrame: CGRect! = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.frame = borderFrame
        borderLayer.cornerRadius = radius
        borderLayer.borderWidth = width
        borderLayer.borderColor = borderColor.cgColor
        imageView.layer.addSublayer(borderLayer)
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
    }
    func setRoundedRectBorderButton(_ button: UIButton, _ width: CGFloat, _ borderColor: UIColor, _ radius: CGFloat){
        button.clipsToBounds = true
        button.layer.cornerRadius = radius
        button.layer.borderColor = borderColor.cgColor
        button.layer.borderWidth = width
    }
    /// Camera/album thumbs used IUO image/size and `croppedImage!`.
    /// Missing image, zero size, or a failed graphics context must not crash create.
    func cropImage(_ image: UIImage?, _ newSize: CGSize?) -> UIImage? {
        return ImageCropPolicy.croppedImage(image, targetSize: newSize)
    }
    func heightString(width: CGFloat, font: UIFont, string: String) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }


    
    func getDistanceFrom(lat:CGFloat, lon:CGFloat) -> String{
        let coordinate₀ = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        
        return getDistanceFrom(loc:coordinate₀)
    }
    func getDistanceFrom(loc:CLLocation?) -> String{
        guard let loc = loc else {
            return "-"
        }
        if loc.coordinate.latitude == 0 && loc.coordinate.longitude == 0 {
            return "-"
        }
        guard let userLocation = HulaUser.sharedInstance.location else {
            return "-"
        }
        if userLocation.coordinate.latitude == 0 && userLocation.coordinate.longitude == 0 {
            return "-"
        }
        let distanceInMeters = loc.distance(from: userLocation) // result is in meters

        var distance = round( distanceInMeters / 1609 );
        var dist_unit = NSLocalizedString("miles", comment: "");
        if (!inUSA(userLocation)){
            distance = round( distanceInMeters / 1000 );
            dist_unit = NSLocalizedString("kilometers", comment: "");
        }
        if (distance<1){
            distance = round( distance*10 ) / 10;
        } else {
            if (distance>1000){
                //distance = distance
                //return "Too far"
                return "\(Int(distance)) " + dist_unit
            }
        }
        return "\(distance) " + dist_unit
    }
    func inUSA(_ loc:CLLocation) -> Bool{
        if (loc.coordinate.longitude < -50) && (loc.coordinate.longitude > -170){
            return true
        }
        return false;
    }
    func getCGDistanceFrom(loc:CLLocation?) -> CGFloat{
        guard let loc = loc, let userLocation = HulaUser.sharedInstance.location else {
            return CGFloat(0.0)
        }
        let distanceInMeters:CGFloat = CGFloat(loc.distance(from: userLocation)) // result is in meters
        return distanceInMeters  / 1609.0
    }
    
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        return RelativeDatePolicy.timeAgo(from: date as Date, now: Date(), numericDates: numericDates)
    }
    
    func isoDateToNSDate(date:String) -> NSDate{
        if let parsed = RelativeDatePolicy.parseISO(date) {
            return parsed as NSDate
        }
        return NSDate()
    }

    /// Safe relative-date label for optional API date strings (notifications/chat).
    /// Returns empty string when date is missing/blank so callers never force-unwrap.
    func relativeDateLabel(fromISO dateString: String?, numericDates: Bool = false) -> String {
        guard let dateString = dateString, dateString.count > 0 else {
            return ""
        }
        let date = isoDateToNSDate(date: dateString)
        return timeAgoSinceDate(date: date, numericDates: numericDates)
    }

    /// Clamps a trade list index so mid-session refreshes cannot OOB-crash open rooms/chat.
    func clampedTradeIndex(_ index: Int, tradeCount: Int) -> Int? {
        guard tradeCount > 0 else {
            return nil
        }
        if index < 0 {
            return 0
        }
        if index >= tradeCount {
            return tradeCount - 1
        }
        return index
    }

    func userImageURL(userId: String) -> String{
        return CommonUtils.userImageURL(apiBase: HulaConstants.apiURL, userId: userId) ?? ""
    }
    func productImageURL(productId: String) -> String{
        return CommonUtils.productImageURL(apiBase: HulaConstants.apiURL, productId: productId) ?? ""
    }
    
    func getThumbFor(url:String) -> String {
        if (url == ""){
            return HulaConstants.noProductThumb
        }
        if (url == HulaConstants.transparentImg){
            return HulaConstants.transparentImg
        }
        var parts = url.components(separatedBy: "/")
        let img_name = "tm_\(parts[parts.count - 1])"
        parts[parts.count - 1] = img_name
        return parts.joined(separator:"/")
    }
    
    
    func showTutorial(arrayTips: [HulaTip], named: String){
        if (currentTip == -1){
            currentTipArr = arrayTips
            self.tutorialToComplete = named
            if let vc = currentTipArr[0].view.parentViewController  {
                if bgViewToRemove != nil{
                    bgViewToRemove.removeFromSuperview()
                }
                bgViewToRemove = UIView(frame: vc.view.frame)
                bgViewToRemove.frame.size.width = max(vc.view.frame.width, vc.view.frame.height) + 100
                bgViewToRemove.frame.size.height = max(vc.view.frame.width, vc.view.frame.height) + 100
                bgViewToRemove.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(removeEasyTips))
                tap.delegate = self
                bgViewToRemove.addGestureRecognizer(tap)
                
                vc.view.addSubview(bgViewToRemove)
            }
            self.showNextTip(false)
        }
    }
    
    func showNextTip(_ direct:Bool){
        //self.lastTip.dismiss()
        //print("shownext")
        self.currentTip += 1
        if (self.currentTip < self.currentTipArr.count){
            var when = DispatchTime.now() + Double(currentTipArr[currentTip].delay)
            if (direct){
                when = DispatchTime.now()
            }
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                if (self.currentTip < self.currentTipArr.count){
                    EasyTipView.show(forView: self.currentTipArr[self.currentTip].view, withinSuperview: self.currentTipArr[self.currentTip].view.parentViewController?.view, text: self.currentTipArr[self.currentTip].text, delegate:self )
                    
                    //self.lastTip = EasyTipView(text: self.currentTipArr[self.currentTip].text)
                    //self.lastTip.show(forView: self.currentTipArr[self.currentTip].view)
                    
                    //self.showNextTip(false)
                } else {
                    self.disarmTutorialOverlay()
                    self.bgViewToRemove.removeFromSuperview()
                    self.currentTip = -1
                    
                    HLDataManager.sharedInstance.applyCompletedTutorial(self.tutorialToComplete)
                    HLDataManager.sharedInstance.writeUserData()
                }
            }
        }else{
            // Tutorial finished: disarm overlay taps before fade so removeEasyTips
            // cannot index currentTipArr with currentTip == -1.
            self.disarmTutorialOverlay()
            self.currentTip = -1
            UIView.animate(withDuration: 0.5, animations: {
                self.bgViewToRemove.alpha = 0
            }, completion: {(success) in
                self.bgViewToRemove.removeFromSuperview()
            })
            
            HLDataManager.sharedInstance.applyCompletedTutorial(self.tutorialToComplete)
            HLDataManager.sharedInstance.writeUserData()
        }
    }
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //print("dismissed")
        self.showNextTip(false)
    }

    /// True when `index` can safely subscript a tip array of `count` items.
    class func isValidTipIndex(_ index: Int, count: Int) -> Bool {
        return index >= 0 && index < count
    }

    func disarmTutorialOverlay() {
        if bgViewToRemove != nil, let gestures = bgViewToRemove.gestureRecognizers {
            for gesture in gestures {
                bgViewToRemove.removeGestureRecognizer(gesture)
            }
        }
    }
    
    func removeEasyTips(){
        //print("removing from...")
        print(self.currentTip)
        // After the last tip, showNextTip sets currentTip = -1 while the dim
        // overlay may still be fading; tapping it must not crash.
        guard CommonUtils.isValidTipIndex(self.currentTip, count: self.currentTipArr.count) else {
            if self.bgViewToRemove != nil {
                self.bgViewToRemove.removeFromSuperview()
            }
            return
        }
        if let prnt = self.currentTipArr[self.currentTip].view.parentViewController?.view {
            for view in prnt.subviews {
                if let tipView = view as? EasyTipView {
                    tipView.dismiss(withCompletion: {
                        //nada
                    })
                }
            }
        }
    }
    
    func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            print(topController)
            return topController;
        } else {
            return nil
        }
        
    }
}

extension CommonUtils {
    /// Parse numeric JSON values that may arrive as Int, Double, Float, or NSNumber.
    /// `as? Float` fails for whole-number JSON values bridged as Int/NSNumber.
    static func floatFromJSON(_ value: Any?) -> Float? {
        if let number = value as? NSNumber {
            // Bool bridges as NSNumber; reject so true/false never become 1/0 money.
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return nil
            }
            return number.floatValue
        }
        if let v = value as? Float {
            return v
        }
        if let v = value as? Double {
            return Float(v)
        }
        if let v = value as? Int {
            return Float(v)
        }
        return nil
    }

    /// Parse integer JSON counts (unread badges, etc.) across Int/Double/NSNumber bridges.
    /// Rejects Bool so `true`/`false` never become unread `1`/`0`.
    static func intFromJSON(_ value: Any?) -> Int? {
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return nil
            }
            return number.intValue
        }
        if let v = value as? Int {
            return v
        }
        if let v = value as? Double {
            return Int(v)
        }
        if let v = value as? Float {
            return Int(v)
        }
        return nil
    }

    /// Soft-parse trade/acceptance flags that may arrive as Bool or 0/1 Int/NSNumber.
    /// Rejects arbitrary numbers and strings so malformed JSON does not flip deal state.
    /// NSNumber is checked before `as? Bool` because non-zero NSNumbers bridge to `true`.
    static func boolFromJSON(_ value: Any?) -> Bool? {
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue
            }
            let asInt = number.intValue
            if number.doubleValue == Double(asInt) && (asInt == 0 || asInt == 1) {
                return asInt == 1
            }
            return nil
        }
        if let v = value as? Int {
            if v == 0 || v == 1 {
                return v == 1
            }
            return nil
        }
        if let v = value as? Bool {
            return v
        }
        return nil
    }

    /// Walk JSON objects that arrive as `[String: Any]` or `NSDictionary`.
    /// Returns nil when the value is not a dictionary so callers keep stale maps.
    static func dictionaryPairs(_ value: Any?) -> [(String, Any)]? {
        if let dict = value as? [String: Any] {
            var pairs: [(String, Any)] = []
            for (key, val) in dict {
                pairs.append((key, val))
            }
            return pairs
        }
        if let dict = value as? NSDictionary {
            var pairs: [(String, Any)] = []
            for (rawKey, val) in dict {
                if let dictKey = rawKey as? String {
                    pairs.append((dictKey, val))
                }
            }
            return pairs
        }
        return nil
    }

    /// Soft-parse `video_requested` maps. JSON bools often arrive as NSNumber 0/1,
    /// so `as? [String:Bool]` drops the whole dictionary and the proof UI resets.
    /// Wholly unparsable values return nil so callers keep stale data.
    static func boolMapFromJSON(_ value: Any?) -> [String:Bool]? {
        if let typed = value as? [String:Bool] {
            return typed
        }
        guard let pairs = dictionaryPairs(value) else {
            return nil
        }
        if pairs.count == 0 {
            return [:]
        }
        var result: [String:Bool] = [:]
        for (key, val) in pairs {
            if let flag = boolFromJSON(val) {
                result[key] = flag
            }
        }
        if result.count == 0 {
            return nil
        }
        return result
    }

    /// Soft-parse `video_url` maps. Mixed NSNull / non-string values fail
    /// `as? [String:String]` and previously wiped every proof URL.
    static func stringMapFromJSON(_ value: Any?) -> [String:String]? {
        if let typed = value as? [String:String] {
            return typed
        }
        guard let pairs = dictionaryPairs(value) else {
            return nil
        }
        if pairs.count == 0 {
            return [:]
        }
        var result: [String:String] = [:]
        for (key, val) in pairs {
            if let s = val as? String {
                result[key] = s
            }
        }
        if result.count == 0 {
            return nil
        }
        return result
    }

    /// Soft-parse product-id / bid-diff arrays. JSON `NSArray` with an `NSNull`
    /// (or mixed) element fails `as? [String]` and previously dropped the whole list.
    /// Missing or wholly non-string values return nil so callers keep stale data.
    static func stringArrayFromJSON(_ value: Any?) -> [String]? {
        if let strings = value as? [String] {
            return strings
        }
        guard let items = value as? [Any] else {
            return nil
        }
        if items.count == 0 {
            return []
        }
        var result: [String] = []
        for item in items {
            if let s = item as? String {
                result.append(s)
            }
        }
        if result.count == 0 {
            return nil
        }
        return result
    }

    /// Reject nil/blank identifiers so callers do not hit `trades//ready` or unwrap IUOs.
    static func nonEmptyTrimmed(_ value: String?) -> String? {
        guard let value = value else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.characters.count == 0 {
            return nil
        }
        return trimmed
    }

    /// Percent-encode a single application/x-www-form-urlencoded field value.
    /// Keeps `&`/`=` as delimiters and encodes `+` so it is not decoded as a space.
    /// Note: `CharacterSet.urlHostAllowed` is NOT safe here — it leaves `&=+` unescaped.
    static func formEncodedValue(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }

    /// Seller/notifications/dashboard cancel PUTs used `status=\(status)` so an
    /// `&`/`=` in the status token would split the form body.
    static func tradeStatusPostString(status: String) -> String {
        return "status=" + formEncodedValue(status)
    }

    /// Chat section key: prefix through hour for full ISO8601, safe for short dates.
    static func chatDateSectionKey(_ date: String) -> String? {
        guard date.count > 0 else { return nil }
        let prefixLen = min(13, date.count)
        let index = date.index(date.startIndex, offsetBy: prefixLen)
        return date.substring(to: index)
    }

    /// Build "City, Country" display text when either geocode field may be missing.
    static func locationDisplayName(city: String?, country: String?) -> String {
        let cityPart = city ?? ""
        let countryPart = country ?? ""
        if cityPart.isEmpty && countryPart.isEmpty {
            return ""
        }
        if cityPart.isEmpty {
            return countryPart
        }
        if countryPart.isEmpty {
            return cityPart
        }
        return cityPart + ", " + countryPart
    }

    /// Path-safe email segment for `/users/resetmail/{email}` after trimming whitespace.
    static func resetMailPathComponent(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 4,
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            !encoded.isEmpty else {
                return nil
        }
        return encoded
    }

    /// Full reset-mail URL. Keeps `resetMailPathComponent` encoding (`@`/`+`)
    /// rather than `encodedPathSegment`, and skips blank/short emails so callers
    /// do not concatenate `users/resetmail/`.
    static func resetMailURL(apiBase: String, email: String?) -> String? {
        guard let email = email, let encoded = resetMailPathComponent(email) else {
            return nil
        }
        var base = apiBase
        if !base.hasSuffix("/") {
            base += "/"
        }
        return base + "users/resetmail/" + encoded
    }

    /// Single API path segment. Rejects blank IDs and encodes `/`, `&`, `=`, `?`,
    /// `#`, and spaces so one identifier cannot invent extra path or query parts.
    /// `urlHostAllowed` leaves `&`/`=` unencoded; `urlPathAllowed` leaves `/`.
    static func encodedPathSegment(_ raw: String?) -> String? {
        guard let trimmed = nonEmptyTrimmed(raw) else {
            return nil
        }
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowed),
            encoded.characters.count > 0 else {
            return nil
        }
        return encoded
    }

    /// Join encoded path segments onto `apiBase`. Any blank/unencodable segment
    /// returns nil so callers skip the request instead of hitting `trades/` or
    /// `products/search/` (and instead of force-unwrapping `addingPercentEncoding`).
    static func apiResourceURL(apiBase: String, path: [String?]) -> String? {
        if path.count == 0 {
            return nil
        }
        var encoded: [String] = []
        for segment in path {
            guard let part = encodedPathSegment(segment) else {
                return nil
            }
            encoded.append(part)
        }
        var base = apiBase
        if !base.hasSuffix("/") {
            base += "/"
        }
        return base + encoded.joined(separator: "/")
    }

    /// Collection endpoint with no ID segment (`categories`, `authenticate`, `me`).
    /// Rejects blank resource names. `trailingSlash` preserves create POSTs that
    /// historically hit `products/` / `trades/` rather than the slash-less list GET.
    static func apiCollectionURL(apiBase: String, resource: String?, trailingSlash: Bool = false) -> String? {
        guard let url = apiResourceURL(apiBase: apiBase, path: [resource]) else {
            return nil
        }
        if trailingSlash && !url.hasSuffix("/") {
            return url + "/"
        }
        return url
    }

    /// Soft-build an http(s) URL for legal/help/share. Blank or unparsable
    /// strings must not crash via `URL(string:)!`.
    static func openableURL(_ raw: String?) -> URL? {
        guard let trimmed = nonEmptyTrimmed(raw) else {
            return nil
        }
        return URL(string: trimmed)
    }

    /// Avatar GET. Blank userId must not hit `users//image`.
    static func userImageURL(apiBase: String, userId: String?) -> String? {
        return apiResourceURL(apiBase: apiBase, path: ["users", userId, "image"])
    }

    /// Product image GET. Blank productId must not hit `products//image`.
    static func productImageURL(apiBase: String, productId: String?) -> String? {
        return apiResourceURL(apiBase: apiBase, path: ["products", productId, "image"])
    }

    /// Inventory listing. Blank userId must not hit `products/user/`.
    static func productsForUserURL(apiBase: String, userId: String?) -> String? {
        return apiResourceURL(apiBase: apiBase, path: ["products", "user", userId])
    }

    /// Home Near You. Coordinates are encoded as path segments so a malformed
    /// stringified Double cannot invent extra path parts.
    static func productsNearURL(apiBase: String, latitude: Double, longitude: Double) -> String? {
        return apiResourceURL(apiBase: apiBase, path: ["products", "near", "\(latitude)", "\(longitude)"])
    }

    /// Product delete. Blank productId must not GET `products//delete`.
    static func productDeleteURL(apiBase: String, productId: String?) -> String? {
        return apiResourceURL(apiBase: apiBase, path: ["products", productId, "delete"])
    }

    /// User GET/PUT. Blank userId must not hit `users/` with a trailing slash only.
    static func userResourceURL(apiBase: String, userId: String?, extra: [String] = []) -> String? {
        var path: [String?] = ["users", userId]
        for e in extra {
            path.append(e)
        }
        return apiResourceURL(apiBase: apiBase, path: path)
    }

    /// Product GET/PUT. Blank productId must not hit `products/`.
    static func productResourceURL(apiBase: String, productId: String?) -> String? {
        return apiResourceURL(apiBase: apiBase, path: ["products", productId])
    }

    /// Trade GET/PUT. Blank tradeId must not hit `trades/`.
    static func tradeResourceURL(apiBase: String, tradeId: String?, extra: [String] = []) -> String? {
        var path: [String?] = ["trades", tradeId]
        for e in extra {
            path.append(e)
        }
        return apiResourceURL(apiBase: apiBase, path: path)
    }

    /// Soft-read a `String!` nick. Nil/blank IUOs must not crash `\(nick!)`.
    static func displayNick(_ nick: String?) -> String {
        return nonEmptyTrimmed(nick) ?? ""
    }

    /// Seller/detail start-trade button. Missing nick still yields a title.
    static func tradeWithButtonTitle(currentlyTrading: Bool, nick: String?) -> String {
        let prefix = currentlyTrading
            ? NSLocalizedString("Currently trading with", comment: "")
            : NSLocalizedString("Trade with", comment: "")
        let name = displayNick(nick)
        if name.characters.count == 0 {
            return prefix
        }
        return prefix + " " + name
    }

    /// Soft-read a create-flow photo slot. Album/URL/NSNull entries must not crash upload.
    static func uiImage(at index: Int, in photos: NSArray?) -> UIImage? {
        guard let photos = photos, index >= 0, index < photos.count else {
            return nil
        }
        return photos.object(at: index) as? UIImage
    }

    /// First documents-directory path, or nil when NSSearchPath returns empty.
    static func documentsDirectoryPath(
        from paths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    ) -> String? {
        guard let first = paths.first, first.characters.count > 0 else {
            return nil
        }
        return first
    }

    /// Session/video-proof file path under documents. Nil when the directory is missing.
    static func sessionFilePath(
        fileName: String,
        documentsDirectory: String? = nil
    ) -> String? {
        guard let dir = documentsDirectory ?? documentsDirectoryPath(),
            dir.characters.count > 0,
            fileName.characters.count > 0 else {
                return nil
        }
        return (dir as NSString).appendingPathComponent(fileName)
    }

    /// Soft-parse a search `found_users` hit into a synthetic product row (`xx_user`).
    /// Missing optional fields default to empty strings; missing `_id` skips the row.
    static func searchUserProduct(from user: NSDictionary) -> HulaProduct? {
        guard let userId = user["_id"] as? String, userId.count > 0 else {
            return nil
        }
        let name = (user["name"] as? String) ?? ""
        let nick = (user["nick"] as? String) ?? ""
        let image = (user["image"] as? String) ?? ""
        let hprod = HulaProduct()
        hprod.productName = String(NSLocalizedString("User", comment: "")) + ": " + name
            + "\n(" + nick + ")"
        hprod.productDescription = nick
        hprod.productImage = image
        hprod.productId = userId
        hprod.productCategoryId = "xx_user"
        return hprod
    }

    /// Form-urlencoded body for `POST /feedback`.
    static func feedbackPostString(tradeId: String, userId: String, comments: String, points: Int) -> String {
        return feedbackPostString(tradeId: tradeId, userId: userId, comments: comments, val: "\(points)")
    }

    /// Same as the Int `val` helper, encoding the score/token so `&`/`=` cannot split the body.
    static func feedbackPostString(tradeId: String, userId: String, comments: String, val: String) -> String {
        return "trade_id=" + formEncodedValue(tradeId)
            + "&user_id=" + formEncodedValue(userId)
            + "&comments=" + formEncodedValue(comments)
            + "&val=" + formEncodedValue(val)
    }

    /// True only when agree HTTP succeeds and the body is a JSON object (not nil/array/string).
    static func agreeResponseSucceeded(ok: Bool, json: Any?) -> Bool {
        return ok && (json as? [String: Any]) != nil
    }

    /// Barter `getUserProducts` identity: require `_id`, default missing title to untitled.
    static func barterProductIdentity(from productData: [String: Any]) -> (id: String, title: String)? {
        guard let id = productData["_id"] as? String, id.count > 0 else {
            return nil
        }
        let title = (productData["title"] as? String) ?? NSLocalizedString("Untitled product", comment: "")
        return (id, title)
    }

    /// Resolve a playable video URL for a trade; nil when missing, blank, or malformed.
    static func playableVideoURL(videoURLs: [String: String], tradeId: String) -> URL? {
        guard let vurl = videoURLs[tradeId], !vurl.isEmpty else {
            return nil
        }
        return URL(string: vurl)
    }

    /// Soft-parse search autocomplete payloads. Always seeds with the typed keyword;
    /// skips malformed rows and duplicates of the seed (no force-unwrap on keyword dicts).
    static func autocompleteKeywords(from json: Any?, seed: String) -> [String] {
        var results = [seed]
        guard let dictionary = json as? [String: Any],
            let keys = dictionary["keywords"] as? [Any] else {
                return results
        }
        for item in keys {
            if let nkw = item as? [String: Any],
                let nkwStr = nkw["keyword"] as? String,
                nkwStr != seed {
                results.append(nkwStr)
            }
        }
        return results
    }

    /// Album pickers must request images only — `availableMediaTypes` includes video,
    /// and video picks previously crashed via `as! UIImage`.
    static func photoLibraryImageMediaTypes() -> [String] {
        return ["public.image"]
    }

    /// Soft-extract the original UIImage from a picker info dictionary.
    static func pickedOriginalImage(from info: [String: Any]) -> UIImage? {
        return info[UIImagePickerControllerOriginalImage] as? UIImage
    }

    /// Soft-filter capture-session inputs. `inputs as! [AVCaptureDeviceInput]` crashes
    /// when the session contains non-device inputs (or is empty/bridged).
    static func captureDeviceInputs(from sessionInputs: [Any]?) -> [AVCaptureDeviceInput] {
        guard let sessionInputs = sessionInputs else { return [] }
        var inputs: [AVCaptureDeviceInput] = []
        for item in sessionInputs {
            if let input = item as? AVCaptureDeviceInput {
                inputs.append(input)
            }
        }
        return inputs
    }

    /// Soft-parse a lat/lng pair from JSON/plist arrays (NSNumber/Int/Double/CGFloat).
    /// Rejects Bool/NSNumber-bool so true never becomes latitude 1.
    static func coordinatePair(from value: Any?) -> (latitude: CLLocationDegrees, longitude: CLLocationDegrees)? {
        var coordinates: [Any]
        if let tmp = value as? [Any] {
            coordinates = tmp
        } else if let tmp = value as? NSArray {
            coordinates = []
            for item in tmp {
                coordinates.append(item)
            }
        } else {
            return nil
        }

        guard coordinates.count >= 2,
            let latitude = coordinateValue(from: coordinates[0]),
            let longitude = coordinateValue(from: coordinates[1]) else {
                return nil
        }
        return (latitude, longitude)
    }

    static func location(fromJSON value: Any?) -> CLLocation? {
        guard let pair = coordinatePair(from: value) else { return nil }
        return CLLocation(latitude: pair.latitude, longitude: pair.longitude)
    }

    private static func coordinateValue(from value: Any) -> CLLocationDegrees? {
        if value is Bool {
            return nil
        }
        if let number = value as? NSNumber {
            let type = String(cString: number.objCType)
            if type == "c" || type == "B" {
                return nil
            }
            return CLLocationDegrees(number.doubleValue)
        }
        if let value = value as? Double {
            return CLLocationDegrees(value)
        }
        if let value = value as? Float {
            return CLLocationDegrees(value)
        }
        if let value = value as? CGFloat {
            return CLLocationDegrees(value)
        }
        if let value = value as? Int {
            return CLLocationDegrees(value)
        }
        return nil
    }

    /// Build the product create/update form body with delimiter-safe encoding.
    static func productFormPostString(title: String,
                                      description: String,
                                      condition: String,
                                      categoryId: String,
                                      imagesCSV: String,
                                      latitude: Double,
                                      longitude: Double) -> String {
        var dataString = "title=" + formEncodedValue(title)
        dataString += "&description=" + formEncodedValue(description)
        dataString += "&condition=" + formEncodedValue(condition)
        dataString += "&category_id=" + formEncodedValue(categoryId)
        dataString += "&images=" + formEncodedValue(imagesCSV)
        dataString += "&lat=\(latitude)"
        dataString += "&lng=\(longitude)"
        return dataString
    }

    /// Home/search seller trade-rate label. Integer JSON feedback must not become "-".
    static func feedbackTradeRateLabel(points: Any?, count: Any?) -> String {
        guard let up = floatFromJSON(points),
            let uc = floatFromJSON(count),
            uc != 0 else {
                return "-"
        }
        let perc = Int(round(up / uc * 100))
        return "\(perc)%"
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    /// Resolve a loadable URL; invalid strings (spaces, bad encoding) fall back to the placeholder.
    class func resolvedImageURL(from urlString: String) -> URL? {
        let candidate = (urlString == "") ? HulaConstants.noProductThumb : urlString
        if let url = URL(string: candidate) {
            return url
        }
        return URL(string: HulaConstants.noProductThumb)
    }

    func loadImageFromURL(urlString: String) {
        // Malformed API/upload URLs make URL(string:) nil — never force-unwrap.
        guard let url = UIImageView.resolvedImageURL(from: urlString) else {
            return
        }
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, options: [.transition(.fade(0.5))]) { (im, er, ty, ur) in
            if !(er == nil) {
                self.kf.setImage(with: URL(string: HulaConstants.noProductThumb), options: [.transition(.fade(0.5))])
            }
        }
        
        
        /*
         
         //old manual way
         
        self.image = nil
        
        // check for cache
        if let cachedImage = imageCache.object(forKey: _urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        
        if let url = NSURL(string: _urlString) {
        
            URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
                //print("getting: \(_urlString)")
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    let image = UIImage(data: data!)
                    self.image = image
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                    if self.image != nil {
                        imageCache.setObject(image!, forKey: _urlString as AnyObject)
                    }
                })
                
            }).resume()
        }
         */
    }
}

extension UIView {
    
    func bouncer() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5,y: 1.5);
        }, completion: { action -> Void in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1,y: 1);
            })
        })
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
// character at position
extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[start ..< end]
    }
}


/// Shared gates for blocking-load, start-trade, and video-proof paths so callers
/// cannot wedge a spinner, cover a listing before POST, or upload a stale proof file.
struct BlockingNetworkLoadUI {
    let hideSpinner: Bool
    let applyPayload: Bool
    /// True only when the server responded but the body is not the expected object.
    /// Transport failure is not session expiry.
    let treatAsExpiredSession: Bool

    static func outcome(ok: Bool, payloadUsable: Bool) -> BlockingNetworkLoadUI {
        return BlockingNetworkLoadUI(
            hideSpinner: true,
            applyPayload: ok && payloadUsable,
            treatAsExpiredSession: ok && !payloadUsable
        )
    }
}

struct StartTradeUIPolicy {
    /// Full-screen overlay must not cover the listing until the trades POST returns success.
    static func shouldExpandOverlay(postCompleted: Bool, postSucceeded: Bool) -> Bool {
        return postCompleted && postSucceeded
    }

    static func shouldOpenSwapView(postSucceeded: Bool) -> Bool {
        return postSucceeded
    }

    /// Seller/detail start-trade body. Missing `other_id` previously crashed via `otherId!`.
    static func postString(productId: String, otherId: String?) -> String? {
        guard let otherId = CommonUtils.nonEmptyTrimmed(otherId) else {
            return nil
        }
        return "product_id=" + CommonUtils.formEncodedValue(productId)
            + "&other_id=" + CommonUtils.formEncodedValue(otherId)
    }
}

struct VideoProofUploadPolicy {
    static func fileName(productId: String, tradeId: String) -> String {
        let safeProduct = sanitizedPathComponent(productId)
        let safeTrade = sanitizedPathComponent(tradeId)
        return "videoproof_\(safeProduct)_\(safeTrade).mov"
    }

    static func shouldUpload(dataAvailable: Bool, writeSucceeded: Bool) -> Bool {
        return dataAvailable && writeSucceeded
    }

    static func sanitizedPathComponent(_ raw: String) -> String {
        return raw.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "..", with: "_")
    }
}

struct CompleteProductProfilePolicy {
    static let serviceCategoryId = "59124d47a0716d0938e9276c"

    static func shouldHideConditionGroup(categoryId: String?) -> Bool {
        return categoryId == serviceCategoryId
    }
}

/// Cash keypad previously force-unwrapped `Int("\(amount)\(digit)")`, which crashes
/// once the concatenated value exceeds `Int.max`.
struct CalculatorAmountPolicy {
    /// The 0 key is tagged 10 in the storyboard; other tags are the digit itself.
    static func digit(fromTag tag: Int) -> Int {
        if tag == 10 {
            return 0
        }
        return tag
    }

    static func appendingDigit(_ digit: Int, to amount: Int) -> Int {
        let newAmount = "\(amount)" + "\(digit)"
        if let parsed = Int(newAmount) {
            return parsed
        }
        return amount
    }

    /// Shortcut keys (+1/+5/+10) used `+=`, which traps on overflow past Int.max.
    static func adding(_ delta: Int, to amount: Int) -> Int {
        if delta <= 0 {
            return amount
        }
        if amount > Int.max - delta {
            return amount
        }
        return amount + delta
    }

    static func removingLastDigit(from amount: Int) -> Int {
        let strAmount = "\(amount)"
        if strAmount.count <= 1 {
            return 0
        }
        let index = strAmount.index(strAmount.startIndex, offsetBy: strAmount.count - 1)
        let newStr = strAmount.substring(to: index)
        if let parsed = Int(newStr) {
            return parsed
        }
        return 0
    }
}

/// Settings password change: validate before POST, encode delimiters, and never
/// force-unwrap empty credentials or a missing user id.
struct PasswordChangePolicy {
    static func validationMessage(current: String?, newPassword: String?, confirmation: String?) -> String? {
        let newPass = newPassword ?? ""
        let currentPass = current ?? ""
        let confirm = confirmation ?? ""
        if newPass.count < 5 {
            return NSLocalizedString("Your new password is too short.", comment: "")
        }
        if currentPass.count < 4 {
            return NSLocalizedString("Your previous password is too short.", comment: "")
        }
        if newPass != confirm {
            return NSLocalizedString("Passwords do not match.", comment: "")
        }
        return nil
    }

    static func postString(current: String, newPassword: String) -> String {
        return "current_pass=" + CommonUtils.formEncodedValue(current)
            + "&new_pass=" + CommonUtils.formEncodedValue(newPassword)
    }

    static func resetPath(userId: String?, apiBase: String = HulaConstants.apiURL) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["users", "resetpass", userId])
    }

    static func shouldPop(httpOk: Bool, json: Any?) -> Bool {
        guard httpOk,
            let dict = json as? [String: Any],
            let message = dict["message"] as? String else {
                return false
        }
        return message == "ok"
    }

    static func serverMessage(httpOk: Bool, json: Any?) -> String? {
        if !httpOk {
            return NSLocalizedString("Connection error. Please try again.", comment: "")
        }
        guard let dict = json as? [String: Any],
            let message = dict["message"] as? String,
            message != "ok" else {
                return nil
        }
        return message
    }
}

/// ZIP editor geocode: skip blank queries (every keystroke used to fire CLGeocoder)
/// and require a locality before overwriting the saved location name.
struct ZipGeocodePolicy {
    static func shouldGeocode(zipCode: String) -> Bool {
        return zipCode.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    }

    static func forwardLocationName(locality: String?, country: String?) -> String? {
        guard let loc = locality, loc.count > 0 else {
            return nil
        }
        let name = CommonUtils.locationDisplayName(city: loc, country: country)
        if name.isEmpty {
            return nil
        }
        return name
    }

    static func reverseLocationName(city: String?, country: String?) -> String? {
        let name = CommonUtils.locationDisplayName(city: city, country: country)
        if name.isEmpty {
            return nil
        }
        return name
    }
}

/// Shared 1–5 star taps used by AlertViewController and post-deal feedback.
/// Storyboard buttons are tagged 11...15; missing senders must not force-cast crash.
struct StarRatingPolicy {
    static let starTagRange = 1...5
    static let buttonTagOffset = 10

    static func rating(fromSenderTag tag: Int) -> Int? {
        let index = tag - buttonTagOffset
        if starTagRange.contains(index) {
            return index
        }
        return nil
    }

    static func rating(from sender: Any?) -> Int? {
        guard let button = sender as? UIButton else {
            return nil
        }
        return rating(fromSenderTag: button.tag)
    }

    static func shouldFillStar(tag: Int, rating: Int) -> Bool {
        return starTagRange.contains(tag) && tag <= rating
    }

    static func shouldAdvancePastRatingStep(points: Int) -> Bool {
        return points > 0
    }

    static func alertResponse(points: Int) -> String {
        if points > 0 {
            return "\(points)"
        }
        return "ok"
    }
}

/// Post-deal reason chips. Missing buttons previously crashed via `(st?.isSelected)!`.
struct FeedbackReasonPolicy {
    static func appended(existing: String, isSelected: Bool?, title: String?) -> String {
        if isSelected != true {
            return existing
        }
        let label = title ?? ""
        return "\(existing) \(label)"
    }
}

/// Tab bar login gate. Tokens shorter than 10 chars are treated as logged out,
/// and only the Home tab (tag 0) is reachable without a session.
struct TabLoginPolicy {
    static let minimumTokenLength = 10

    static func isLoggedIn(token: String?) -> Bool {
        guard let token = token else {
            return false
        }
        return token.characters.count >= minimumTokenLength
    }

    static func shouldAllowTab(itemTag: Int, loggedIn: Bool) -> Bool {
        if itemTag > 0 {
            return loggedIn
        }
        return true
    }

    static func tabItem(at index: Int, in items: [UITabBarItem]?) -> UITabBarItem? {
        guard let items = items, index >= 0, index < items.count else {
            return nil
        }
        return items[index]
    }

    /// Map a child VC to its tab index (this app uses index == item.tag).
    static func itemTag(for viewController: UIViewController, in viewControllers: [UIViewController]?) -> Int? {
        guard let viewControllers = viewControllers else {
            return nil
        }
        return viewControllers.index(of: viewController)
    }

    /// Tab-bar assets. `UIImage(named:)!` crashed launch if a catalog image was missing.
    static func tabImages(from image: UIImage?) -> (selected: UIImage, normal: UIImage)? {
        guard let image = image else {
            return nil
        }
        return (image, image.withRenderingMode(.alwaysOriginal))
    }

    /// `viewDidAppear` used `(navigationController?.viewControllers.count)!`.
    static func shouldTrimNavigationRoot(stackCount: Int?) -> Bool {
        guard let stackCount = stackCount else {
            return false
        }
        return stackCount > 1
    }
}

/// Page-control catalog icons. Stored `UIImage(named:)!` crashed HLPageControl init
/// if house/page assets were missing from the catalog.
struct PageControlPolicy {
    static func catalogImages(
        home: UIImage?,
        homeSelected: UIImage?,
        page: UIImage?,
        pageSelected: UIImage?
    ) -> (home: UIImage, homeSelected: UIImage, page: UIImage, pageSelected: UIImage)? {
        guard let home = home,
            let homeSelected = homeSelected,
            let page = page,
            let pageSelected = pageSelected else {
            return nil
        }
        return (home, homeSelected, page, pageSelected)
    }

    /// Index 0 is the home house icon; later dots are page circles.
    /// Selected vs unselected must not depend on force-unwrapping the image view.
    static func dotImage(
        index: Int,
        currentPage: Int,
        homeIcon: UIImage,
        homeSelIcon: UIImage,
        pageCircle: UIImage,
        pageSelCircle: UIImage
    ) -> UIImage {
        let selected = index == currentPage
        if index == 0 {
            return selected ? homeSelIcon : homeIcon
        }
        return selected ? pageSelCircle : pageCircle
    }

    /// `updateDots` created a UIImageView then immediately used `imageView!`.
    /// Reuse the existing dot when present; otherwise return a fresh view.
    static func resolvedDotImageView(existing: UIImageView?) -> UIImageView {
        if let existing = existing {
            return existing
        }
        return UIImageView()
    }
}

/// Soft-read IBAction senders. Settings/filter/edit/modal used `sender as! UIButton`.
struct ControlSenderPolicy {
    static func tag(from sender: Any?) -> Int? {
        if let control = sender as? UIControl {
            return control.tag
        }
        return nil
    }

    /// Camera/create photo taps used `(sender.view?.tag)!`.
    static func viewTag(from gesture: UIGestureRecognizer?) -> Int? {
        guard let view = gesture?.view else {
            return nil
        }
        return view.tag
    }
}

struct Device {
    // iDevice detection code
    static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA           = UIScreen.main.scale >= 2.0
    
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH   = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6         = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P        = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X         = IS_IPHONE && SCREEN_MAX_LENGTH == 812
}


extension UIImagePickerController{
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}

class LandscapeAVPlayerController: AVPlayerViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
}

/// Lookup for incoming pending offers. Closed/ended trades must not be treated as
/// live offers, otherwise Accept/Decline is shown and `getTradeWith` returns "".
struct PendingOfferPolicy {
    static func isLiveOfferStatus(_ status: String) -> Bool {
        return status == HulaConstants.pending_status || status == HulaConstants.sent_status
    }

    static func otherHasNotAgreed(_ trade: [String: Any]) -> Bool {
        return CommonUtils.boolFromJSON(trade["other_agree"]) == false
    }

    static func isPendingIncomingOffer(_ trade: [String: Any], fromUser: String, currentUserId: String) -> Bool {
        if fromUser.characters.count == 0 || currentUserId.characters.count == 0 {
            return false
        }
        guard let ownerId = trade["owner_id"] as? String,
            let otherId = trade["other_id"] as? String,
            let status = trade["status"] as? String else {
                return false
        }
        return otherHasNotAgreed(trade)
            && ownerId == fromUser
            && otherId == currentUserId
            && isLiveOfferStatus(status)
    }

    static func tradeId(withUser userId: String, currentUserId: String, currentTrades: [NSDictionary], allTrades: [NSDictionary]) -> String {
        for tr in currentTrades {
            if let trade = tr as? [String: Any] {
                if (trade["owner_id"] as? String) == userId || (trade["other_id"] as? String) == userId {
                    if let id = trade["_id"] as? String, id.characters.count > 0 {
                        return id
                    }
                }
            }
        }
        for tr in allTrades {
            if let trade = tr as? [String: Any], isPendingIncomingOffer(trade, fromUser: userId, currentUserId: currentUserId) {
                if let id = trade["_id"] as? String, id.characters.count > 0 {
                    return id
                }
            }
        }
        return ""
    }

    static func isOffered(withUser userId: String, currentUserId: String, currentTrades: [NSDictionary], allTrades: [NSDictionary]) -> Bool {
        for tr in currentTrades {
            if let trade = tr as? [String: Any] {
                if (trade["other_id"] as? String) == userId && (trade["status"] as? String) == HulaConstants.pending_status {
                    return true
                }
            }
        }
        for tr in allTrades {
            if let trade = tr as? [String: Any], isPendingIncomingOffer(trade, fromUser: userId, currentUserId: currentUserId) {
                return true
            }
        }
        return false
    }

    static func shouldRunOfferAction(tradeId: String) -> Bool {
        return tradeId.characters.count > 0
    }
}

/// Login/signup/reset field reads. `UITextField.text!` crashes when the outlet
/// text is nil, and login/reset next-buttons were tappable with short credentials.
struct AuthFormPolicy {
    static let minimumFieldLength = 5

    static func fieldText(_ raw: String?) -> String {
        return raw ?? ""
    }

    static func shouldEnableNext(text: String?) -> Bool {
        return fieldText(text).characters.count >= minimumFieldLength
    }

    static func shouldEnableLogin(email: String?, password: String?) -> Bool {
        return shouldEnableNext(text: email) && shouldEnableNext(text: password)
    }

    static func loginCredentials(email: String?, password: String?) -> (email: String, password: String)? {
        guard shouldEnableLogin(email: email, password: password) else {
            return nil
        }
        return (fieldText(email), fieldText(password))
    }

    /// Signup next historically allowed any non-empty value (animation still uses >4).
    static func shouldAdvanceSignup(fieldText raw: String?) -> Bool {
        return fieldText(raw).characters.count > 0
    }
}

/// Facebook app-invite placeholders used `URL(string:)!`. Blank or malformed
/// app-link strings must skip the dialog instead of crashing.
struct FacebookInvitePolicy {
    static let defaultAppLink = "https://fb.me/YOUR_FACEBOOK_APP_ID"
    static let defaultPreviewImage = "https://hula.trading/img/logo-big.png"

    static func inviteURLs(
        appLink: String? = defaultAppLink,
        previewImage: String? = defaultPreviewImage
    ) -> (appLink: URL, previewImageURL: URL?)? {
        guard let link = CommonUtils.openableURL(appLink) else {
            return nil
        }
        return (link, CommonUtils.openableURL(previewImage))
    }
}

/// UILabel / UITextField / UITextView optional text and font. Storyboard outlets
/// expose `String?` / `UIFont?`; historical `text!` / `font!` crash Home search,
/// product create, description layout, chat row height, and tab titles.
struct LabelMetricsPolicy {
    static let defaultFontSize: CGFloat = 14
    static let defaultKern: CGFloat = 2.33

    static func text(_ raw: String?) -> String {
        return raw ?? ""
    }

    static func resolvedFont(_ font: UIFont?) -> UIFont {
        return font ?? UIFont.systemFont(ofSize: defaultFontSize)
    }

    static func layoutHeight(
        width: CGFloat,
        font: UIFont?,
        text: String?,
        extra: CGFloat = 0,
        scale: CGFloat = 1,
        suffix: String = ""
    ) -> CGFloat {
        let measured = CommonUtils.sharedInstance.heightString(
            width: width,
            font: resolvedFont(font),
            string: self.text(text) + suffix
        )
        return measured * scale + extra
    }

    static func truncated(_ raw: String?, maxLength: Int) -> String {
        let str = text(raw)
        if maxLength <= 0 {
            return ""
        }
        if str.characters.count <= maxLength {
            return str
        }
        let index = str.index(str.startIndex, offsetBy: maxLength)
        return str.substring(to: index)
    }

    static func clampedField(_ raw: String?, limit: Int) -> (text: String, remaining: Int) {
        let clipped = truncated(raw, maxLength: limit)
        return (clipped, limit - clipped.characters.count)
    }

    static func kernedTitle(_ raw: String?, spacing: CGFloat = defaultKern) -> NSAttributedString {
        return NSAttributedString(string: text(raw), attributes: [NSKernAttributeName: spacing])
    }

    static func localizedField(_ raw: String?, capitalized: Bool = false) -> String {
        let value = NSLocalizedString(text(raw), comment: "")
        if capitalized {
            return value.capitalized
        }
        return value
    }
}

/// Named catalog fonts. Home EasyTipView used `UIFont(name:)!`; a missing
/// PostScript name crashes the first logged-in screen. Other headers assigned
/// nil fonts when HelveticaNeue was absent.
struct CatalogFontPolicy {
    static func font(named name: String?, size: CGFloat) -> UIFont {
        if let name = name, name.characters.count > 0, let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
}

/// Center-crop math used by camera/album thumbs. Zero or missing sizes skip
/// the graphics context instead of dividing by zero or unwrapping a nil image.
struct ImageCropPolicy {
    static func cropArea(imageSize: CGSize, targetSize: CGSize) -> CGRect? {
        if imageSize.width <= 0 || imageSize.height <= 0 || targetSize.width <= 0 || targetSize.height <= 0 {
            return nil
        }
        let hRatio = Double(targetSize.width / imageSize.width)
        let vRatio = Double(targetSize.height / imageSize.height)
        let ratio: Double
        let offset: CGPoint
        if hRatio > vRatio {
            ratio = hRatio
            let delta = Double(CGFloat(ratio) * imageSize.height - targetSize.height)
            offset = CGPoint(x: 0.0, y: delta / 2)
        } else {
            ratio = vRatio
            let delta = Double(CGFloat(ratio) * imageSize.width - targetSize.width)
            offset = CGPoint(x: delta / 2, y: 0.0)
        }
        return CGRect(
            x: -offset.x,
            y: -offset.y,
            width: CGFloat(ratio) * imageSize.width,
            height: CGFloat(ratio) * imageSize.height
        )
    }

    static func croppedImage(_ image: UIImage?, targetSize: CGSize?) -> UIImage? {
        guard let image = image else {
            return nil
        }
        guard let targetSize = targetSize,
            let area = cropArea(imageSize: image.size, targetSize: targetSize) else {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1)
        UIRectClip(area)
        image.draw(in: area)
        let cropped = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return cropped ?? image
    }
}

/// Settings/edit-product fullscreen used `image!` after `if image != nil`.
/// Camera capture rebuilt the listing photos the same way. Kingfisher can
/// still leave the view empty, so presentation and capture must optional-bind.
struct LoadedImagePolicy {
    static func imageForPresentation(_ image: UIImage?) -> UIImage? {
        return image
    }

    static func loadedPhotos(_ images: [UIImage?]) -> [UIImage] {
        var photos: [UIImage] = []
        for image in images {
            if let image = image {
                photos.append(image)
            }
        }
        return photos
    }
}

/// Product galleries and intro paging used `offset / width` then `Int` /
/// `Int(round:)`. A zero-width frame (before layout) produced Inf and
/// trapped when converted to Int, crashing photo paging and onboarding.
struct ScrollPagePolicy {
    static func pageIndex(offset: CGFloat, pageWidth: CGFloat, rounded: Bool) -> Int {
        guard pageWidth > 0, offset.isFinite, pageWidth.isFinite else {
            return 0
        }
        let raw = offset / pageWidth
        guard raw.isFinite else {
            return 0
        }
        if rounded {
            return Int(round(raw))
        }
        return Int(raw)
    }

    static func roundedPageIndex(offset: CGFloat, pageWidth: CGFloat) -> Int {
        return pageIndex(offset: offset, pageWidth: pageWidth, rounded: true)
    }

    static func truncatedPageIndex(offset: CGFloat, pageWidth: CGFloat) -> Int {
        return pageIndex(offset: offset, pageWidth: pageWidth, rounded: false)
    }
}

/// Barter drag snapshots used `UIGraphicsGetCurrentContext()!`. A failed
/// image context (zero-size cell / missing context) must skip the snapshot
/// instead of crashing mid-gesture.
struct ViewSnapshotPolicy {
    static func canSnapshot(size: CGSize) -> Bool {
        return size.width > 0 && size.height > 0
    }

    static func snapshotImage(from view: UIView?) -> UIImage? {
        guard let view = view, canSnapshot(size: view.bounds.size) else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        view.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/// Chat, past-trade, and notification timestamps. Historical `timeAgoSinceDate`
/// force-unwrapped every `DateComponents` field; `daysBetween` unwrapped `day!`;
/// `isoDateToNSDate` only accepted fractional seconds and treated other valid
/// ISO strings as "now". Missing components must fall through, not crash.
struct RelativeDatePolicy {
    static let oldNotificationDays = 3

    static func component(_ value: Int?) -> Int {
        return value ?? 0
    }

    static func parseISO(_ raw: String?) -> Date? {
        guard let raw = raw, raw.characters.count > 0 else {
            return nil
        }
        if let date = raw.dateFromISO8601 {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = formatter.date(from: raw) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.date(from: raw)
    }

    static func timeAgoLabel(
        year: Int,
        month: Int,
        weekOfYear: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        numericDates: Bool
    ) -> String {
        if year >= 2 {
            return "\(year) " + NSLocalizedString("years ago", comment: "")
        } else if year >= 1 {
            if numericDates {
                return NSLocalizedString("1 year ago", comment: "")
            }
            return NSLocalizedString("Last year", comment: "")
        } else if month >= 2 {
            return "\(month) " + NSLocalizedString("months ago", comment: "")
        } else if month >= 1 {
            if numericDates {
                return NSLocalizedString("1 month ago", comment: "")
            }
            return NSLocalizedString("Last month", comment: "")
        } else if weekOfYear >= 2 {
            return "\(weekOfYear) " + NSLocalizedString("weeks ago", comment: "")
        } else if weekOfYear >= 1 {
            if numericDates {
                return NSLocalizedString("1 week ago", comment: "")
            }
            return NSLocalizedString("Last week", comment: "")
        } else if day >= 2 {
            return "\(day) " + NSLocalizedString("days ago", comment: "")
        } else if day >= 1 {
            if numericDates {
                return NSLocalizedString("1 day ago", comment: "")
            }
            return NSLocalizedString("Yesterday", comment: "")
        } else if hour >= 2 {
            return "\(hour) " + NSLocalizedString("hours ago", comment: "")
        } else if hour >= 1 {
            if numericDates {
                return NSLocalizedString("1 hour ago", comment: "")
            }
            return NSLocalizedString("An hour ago", comment: "")
        } else if minute >= 2 {
            return "\(minute) " + NSLocalizedString("minutes ago", comment: "")
        } else if minute >= 1 {
            if numericDates {
                return NSLocalizedString("1 minute ago", comment: "")
            }
            return NSLocalizedString("A minute ago", comment: "")
        } else if second >= 3 {
            return "\(second) seconds ago" + NSLocalizedString("seconds ago", comment: "")
        }
        return NSLocalizedString("Just now", comment: "")
    }

    static func timeAgo(
        from date: Date,
        now: Date,
        numericDates: Bool,
        calendar: Calendar = Calendar.current
    ) -> String {
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let earliest = now < date ? now : date
        let latest = now < date ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        return timeAgoLabel(
            year: component(components.year),
            month: component(components.month),
            weekOfYear: component(components.weekOfYear),
            day: component(components.day),
            hour: component(components.hour),
            minute: component(components.minute),
            second: component(components.second),
            numericDates: numericDates
        )
    }

    static func daysBetween(from start: Date, to end: Date, calendar: Calendar = Calendar.current) -> Int {
        return component(calendar.dateComponents([.day], from: start, to: end).day)
    }

    static func isOldNotification(daysSince: Int, threshold: Int = oldNotificationDays) -> Bool {
        return daysSince > threshold
    }
}

/// Post-deal feedback reason buttons used `UIGraphicsGetCurrentContext()!` for
/// a 1x1 fill. A failed image context (or a zero-size request) must skip the
/// background image instead of crashing the rating modal.
struct SolidColorImagePolicy {
    static func canDraw(size: CGSize) -> Bool {
        return size.width > 0 && size.height > 0
    }

    static func image(color: UIColor?, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        guard let color = color, canDraw(size: size) else {
            return nil
        }
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/// Inventory GPS persist and ZIP/location editors used `locations[0]`. An
/// empty Core Location callback must skip the write instead of crashing.
struct LocationUpdatePolicy {
    static func firstLocation(from locations: [CLLocation]?) -> CLLocation? {
        guard let locations = locations, locations.count > 0 else {
            return nil
        }
        return locations[0]
    }
}

/// Create/edit "set as featured" used unbounded `swap(&[0], &[index])` and
/// `arrProductPhotoLink[0]`. A stale editor index after a delete must no-op.
/// Barter add/remove animations used `arrProductPhotoLink[0]` behind a disabled
/// flag; firstURL stays safe if that path is re-enabled.
/// Promote/remove used IUO photo arrays; a nil album after a partial populate
/// must no-op instead of crashing the editor or create-flow camera.
struct FeaturedPhotoPolicy {
    static func canPromote(index: Int, count: Int) -> Bool {
        return index > 0 && index < count
    }

    static func swappedLinks(_ links: [String]?, promoting index: Int) -> [String]? {
        guard let links = links, canPromote(index: index, count: links.count) else {
            return nil
        }
        var copy = links
        let featured = copy[0]
        copy[0] = copy[index]
        copy[index] = featured
        return copy
    }

    static func promoteObject(in array: NSMutableArray?, at index: Int) -> Bool {
        guard let array = array, canPromote(index: index, count: array.count) else {
            return false
        }
        let featured = array.object(at: 0)
        let selected = array.object(at: index)
        array.replaceObject(at: 0, with: selected)
        array.replaceObject(at: index, with: featured)
        return true
    }

    static func removeObject(in array: NSMutableArray?, at index: Int) -> Bool {
        guard let array = array, index >= 0 && index < array.count else {
            return false
        }
        array.removeObject(at: index)
        return true
    }

    static func removingLink(_ links: [String]?, at index: Int) -> [String]? {
        guard let links = links, index >= 0 && index < links.count else {
            return nil
        }
        var copy = links
        copy.remove(at: index)
        return copy
    }

    static func firstURL(_ links: [String]?) -> String? {
        guard let links = links, links.count > 0 else {
            return nil
        }
        return CommonUtils.nonEmptyTrimmed(links[0])
    }
}

/// Edit-product and the barter product modal used IUO
/// `arrProductPhotoLink.count` / `[i]`. A partial JSON populate with a nil
/// gallery must show zero slots instead of crashing the pager or picture count.
struct PhotoGalleryPolicy {
    static let lastEditorSlotIndex = 3

    static func links(_ links: [String]?) -> [String] {
        return links ?? []
    }

    static func count(_ links: [String]?) -> Int {
        return self.links(links).count
    }

    static func url(at index: Int, in links: [String]?) -> String? {
        let list = self.links(links)
        guard index >= 0 && index < list.count else {
            return nil
        }
        return list[index]
    }

    static func nonEmptyURL(at index: Int, in links: [String]?) -> String? {
        guard let url = url(at: index, in: links), UserIdentityPolicy.hasNonEmptyValue(url) else {
            return nil
        }
        return url
    }

    static func pictureCountText(_ links: [String]?) -> String {
        return "\(count(links))"
    }

    /// The 4th editor slot is the add-camera chip until four photos exist.
    /// `currentEditingIndex == 3 && arrProductPhotoLink.count < 4` crashed when
    /// the IUO array was nil; nil counts as 0 and still opens the camera.
    static func shouldOpenCameraForLastSlot(slotIndex: Int, linkCount: Int) -> Bool {
        return slotIndex == lastEditorSlotIndex && linkCount < (lastEditorSlotIndex + 1)
    }
}

/// Create-flow / camera / inventory thumbs used IUO `arrProductPhotos.count`.
/// A nil capture album must look empty instead of crashing slot layout.
struct LocalPhotoAlbumPolicy {
    static func count(_ photos: NSArray?) -> Int {
        return photos?.count ?? 0
    }

    static func hasPhotos(_ photos: NSArray?) -> Bool {
        return count(photos) > 0
    }

    static func image(at index: Int, in photos: NSArray?) -> UIImage? {
        return CommonUtils.uiImage(at: index, in: photos)
    }
}

/// Trade-room accelerometer used `OperationQueue.current!`. A nil current
/// queue (background hop with no queue) must fall back to main.
struct MotionUpdatePolicy {
    static func updatesQueue(_ current: OperationQueue?) -> OperationQueue {
        return current ?? OperationQueue.main
    }
}

/// Inventory listed newest-first as `count - row - 1`, then clamped empty
/// arrays to index 0 (`array[0]` crash) and OOB rows to a neighbor listing.
/// Empty or out-of-range rows must skip instead of opening the wrong product.
struct InventoryRowPolicy {
    static func product(at index: Int, in products: [HulaProduct]) -> HulaProduct? {
        guard index >= 0 && index < products.count else {
            return nil
        }
        return products[index]
    }

    static func reversedIndex(row: Int, count: Int) -> Int? {
        guard count > 0, row >= 0, row < count else {
            return nil
        }
        return count - row - 1
    }

    static func product(atRow row: Int, in products: [HulaProduct]) -> HulaProduct? {
        guard let index = reversedIndex(row: row, count: products.count) else {
            return nil
        }
        return products[index]
    }
}

/// Trade-room pager `goTo(page:)` only checked `page < count`, so a negative
/// page (or replacing `orderedViewControllers[1]` when the stack is short)
/// crashed instead of staying on the lobby.
struct TradeRoomPagePolicy {
    static let tradeRoomPage = 1

    static func pageIndex(_ page: Int, count: Int) -> Int? {
        guard page >= 0 && page < count else {
            return nil
        }
        return page
    }

    static func replacing(
        _ controllers: [UIViewController],
        at page: Int,
        with replacement: UIViewController
    ) -> [UIViewController] {
        guard let index = pageIndex(page, count: controllers.count) else {
            return controllers
        }
        var result = controllers
        result[index] = replacement
        return result
    }
}

/// Home / search / inventory compared IUO `trading_count` and force-converted
/// `productOwner as String`. A nil count or owner (unpopulated listing) crashed
/// the table instead of hiding the badge or skipping the avatar lookup.
struct ProductListingPolicy {
    static func showsMultipleTrades(_ tradingCount: Int?) -> Bool {
        return (tradingCount ?? 0) > 1
    }

    static func ownerId(_ owner: String?) -> String {
        return owner ?? ""
    }

    static func imageURL(_ image: String?) -> String {
        return image ?? ""
    }

    /// Search filters used `usersList.object(forKey: productOwner)` with an IUO
    /// owner. A nil NSDictionary key crashes; missing owners skip reputation.
    static func seller(in users: NSDictionary?, ownerId owner: String?) -> NSDictionary? {
        guard let users = users else {
            return nil
        }
        return users.object(forKey: ownerId(owner)) as? NSDictionary
    }
}

/// Home Near You and search listed `productArray[indexPath.row]` /
/// `filteredList[indexPath.row]` without a bounds check. A reload that
/// shrinks the list while a stale row is still on screen crashed discovery
/// instead of skipping the cell or tap.
struct ListingIndexPolicy {
    static func product(at index: Int, in products: [HulaProduct]) -> HulaProduct? {
        guard index >= 0 && index < products.count else {
            return nil
        }
        return products[index]
    }
}

/// Home Near You, profile PUT, inventory update, and session plist used
/// `location.coordinate` on a `CLLocation!`. A nil GPS fix must not crash
/// those paths; unusable 0,0 still omits lat/lng from the profile PUT.
struct UserCoordinatePolicy {
    static func coordinates(_ location: CLLocation?) -> (latitude: Double, longitude: Double)? {
        guard let location = location else {
            return nil
        }
        return (location.coordinate.latitude, location.coordinate.longitude)
    }

    static func usableCoordinates(_ location: CLLocation?) -> (latitude: Double, longitude: Double)? {
        guard let coords = coordinates(location), coords.latitude != 0, coords.longitude != 0 else {
            return nil
        }
        return coords
    }

    /// Session plist historically always wrote a 2-element array. Nil location
    /// must persist 0,0 instead of crashing `user.location.coordinate`.
    static func plistCoordinates(_ location: CLLocation?) -> [CGFloat] {
        let coords = coordinates(location) ?? (latitude: 0, longitude: 0)
        return [CGFloat(coords.latitude), CGFloat(coords.longitude)]
    }
}

/// UserData.plist `setObject` used IUO strings and `location.coordinate`.
/// Nil token/nick/location after a partial restore must persist empty
/// strings and 0,0 instead of crashing logout/save.
struct SessionWritePolicy {
    static func stringValue(_ value: String?) -> String {
        return value ?? ""
    }

    static func identityDictionary(from user: HulaUser) -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        applyIdentity(from: user, to: dict)
        return dict
    }

    static func applyIdentity(from user: HulaUser, to dict: NSMutableDictionary) {
        dict.setObject(stringValue(user.token), forKey: "token" as NSCopying)
        dict.setObject(stringValue(user.userId), forKey: "userId" as NSCopying)
        dict.setObject(stringValue(user.userNick), forKey: "userNick" as NSCopying)
        dict.setObject(stringValue(user.userName), forKey: "userName" as NSCopying)
        dict.setObject(stringValue(user.userEmail), forKey: "userEmail" as NSCopying)
        dict.setObject(user.maxTrades, forKey: "max_trades" as NSCopying)
        dict.setObject(stringValue(user.userLocationName), forKey: "userLocationName" as NSCopying)
        dict.setObject(UserCoordinatePolicy.plistCoordinates(user.location), forKey: "userLocation" as NSCopying)
        dict.setObject(stringValue(user.userPhotoURL), forKey: "userPhotoURL" as NSCopying)
        dict.setObject(stringValue(user.userBio), forKey: "userBio" as NSCopying)
        dict.setObject(user.numProducts, forKey: "numProducts" as NSCopying)
    }
}

/// Profile, My Products, and Notifications store `last_logged_user` as a
/// non-optional String (default ""). They compared it with IUO `userId` and
/// assigned that id back. A nil viewer crashed the compare and the write.
/// Nil becomes "" so it matches the initial stored id and does not reload.
/// Do not use `TradeTurnPolicy.idsMatch` (nil must not look like a switch
/// against ""). Do not trim. Do not write nil into the String.
struct LoggedUserSwitchPolicy {
    static func storedId(_ userId: String?) -> String {
        return SessionWritePolicy.stringValue(userId)
    }

    static func shouldReload(lastLoggedUser: String, userId: String?) -> Bool {
        return lastLoggedUser != storedId(userId)
    }
}

/// Profile stores `current_image_url` as a non-optional String (default "").
/// viewWillAppear, viewDidAppear, the /me payload, settings, and fullscreen
/// compared or passed IUO `userPhotoURL` into `String` parameters
/// (`loadImageFromURL`, `getThumbFor`, and the stored-url assignment).
/// A nil photo crashed before the image load. Nil becomes "" so it matches
/// the initial stored url and shows the placeholder instead of looking like
/// a photo change. Do not trim. Settings keeps `hasDisplayValue` (>1);
/// a one-character url is still a remote profile photo.
struct ProfilePhotoPolicy {
    static func storedURL(_ photoURL: String?) -> String {
        return SessionWritePolicy.stringValue(photoURL)
    }

    /// viewDidAppear outer check. Empty and nil show the profile placeholder.
    static func showsRemotePhoto(_ photoURL: String?) -> Bool {
        return storedURL(photoURL) != ""
    }

    /// Reload the thumb only when the remote url is non-empty and differs.
    /// A nil photo is not a change against the initial "".
    static func shouldRefresh(currentURL: String, photoURL: String?) -> Bool {
        let stored = storedURL(photoURL)
        return stored != "" && currentURL != stored
    }

    /// viewWillAppear, fullscreen, settings, and the /me payload pass this
    /// into `loadImageFromURL(urlString:)`.
    static func loadURL(_ photoURL: String?) -> String {
        return storedURL(photoURL)
    }

    /// viewDidAppear thumb. Nil and "" follow `getThumbFor` (placeholder thumb).
    static func thumbURL(_ photoURL: String?) -> String {
        return CommonUtils.sharedInstance.getThumbFor(url: storedURL(photoURL))
    }
}

/// Multipart `appendString` used `string.data(using: .utf8)!`. A failed
/// conversion must skip the chunk instead of crashing photo/video upload.
struct UTF8DataPolicy {
    static func data(from string: String) -> Data? {
        return string.data(using: String.Encoding.utf8, allowLossyConversion: false)
    }
}

/// IUO identity strings (`userId`, `token`, social tokens, profile fields)
/// used `.count` / `==` and crashed after a partial restore. Nil must count
/// as empty. HTTP/identification historically used `token.count > 10` (strict),
/// which is not TabLoginPolicy's `>= 10` tab-bar gate.
struct UserIdentityPolicy {
    static func characterCount(_ value: String?) -> Int {
        return SessionWritePolicy.stringValue(value).characters.count
    }

    static func hasNonEmptyValue(_ value: String?) -> Bool {
        return characterCount(value) > 0
    }

    /// `HulaUser.isUserLoggedIn`: both userId and token non-empty (any length).
    static func isLoggedIn(userId: String?, token: String?) -> Bool {
        return hasUserId(userId) && hasNonEmptyValue(token)
    }

    /// Inventory/barter/seller/start-trade used `userId.count>0`.
    static func hasUserId(_ userId: String?) -> Bool {
        return hasNonEmptyValue(userId)
    }

    /// HTTP `x-access-token` and identification auto-close used `token.count > 10`.
    /// A 10-char token stays logged in on the tab bar (`>= 10`) but must not
    /// attach an auth header or skip identification.
    static func hasAccessToken(_ token: String?) -> Bool {
        return characterCount(token) > TabLoginPolicy.minimumTokenLength
    }

    static func accessTokenHeaderValue(_ token: String?) -> String? {
        if !hasAccessToken(token) {
            return nil
        }
        return SessionWritePolicy.stringValue(token)
    }

    /// Settings/seller display used `.count>1`. One-character fields stay placeholders.
    static func hasDisplayValue(_ value: String?) -> Bool {
        return characterCount(value) > 1
    }

    /// Profile social sheet used `.count == 0` to offer Facebook/Twitter/LinkedIn.
    static func isSocialTokenMissing(_ token: String?) -> Bool {
        return characterCount(token) == 0
    }

    static func isEmailVerified(_ status: String?) -> Bool {
        return SessionWritePolicy.stringValue(status) == "verified"
    }

    /// Complete-profile used `== ""` on IUO name/nick/bio/photo. Nil must be
    /// incomplete instead of crashing or looking complete.
    static func isIncompleteProfile(name: String?, nick: String?, bio: String?, photoURL: String?) -> Bool {
        return characterCount(name) == 0
            || characterCount(nick) == 0
            || characterCount(bio) == 0
            || characterCount(photoURL) == 0
    }
}

/// Product/trade IUO form fields used `formEncodedValue(self.productName)` and
/// `arrProductPhotoLink.joined`. A partial JSON populate with nil IUOs crashed
/// listing/trade PUT instead of encoding empty values.
struct FormFieldPolicy {
    static func encoded(_ value: String?) -> String {
        return CommonUtils.formEncodedValue(SessionWritePolicy.stringValue(value))
    }

    static func joined(_ values: [String]?, separator: String = ",") -> String {
        return encoded(csv(values, separator: separator))
    }

    static func csv(_ values: [String]?, separator: String = ",") -> String {
        return (values ?? []).joined(separator: separator)
    }
}

/// Product/trade IUO identifiers and status. `tradeId.count`, `productId.count`,
/// `productImage.isEmpty`, and `productStatus != "traded"` crashed after a
/// partial populate instead of treating nil as empty.
struct ProductIdentityPolicy {
    static func hasIdentifier(_ value: String?) -> Bool {
        return UserIdentityPolicy.hasNonEmptyValue(value)
    }

    static func statusValue(_ status: String?) -> String {
        return SessionWritePolicy.stringValue(status)
    }

    static func isTraded(_ status: String?) -> Bool {
        return statusValue(status) == "traded"
    }

    static func isDeleted(_ status: String?) -> Bool {
        return statusValue(status) == "deleted"
    }

    static func isCashChip(_ productId: String?) -> Bool {
        return statusValue(productId) == "xmoney"
    }

    static func identifiersMatch(_ lhs: String?, _ rhs: String?) -> Bool {
        return statusValue(lhs) == statusValue(rhs)
    }

    static func featuredImageIsEmpty(_ image: String?) -> Bool {
        return statusValue(image).isEmpty
    }

    /// Unencoded `images=` CSV. Callers that already percent-encode the form
    /// body must use this rather than `FormFieldPolicy.joined`.
    static func photoLinksCSV(_ links: [String]?) -> String {
        return FormFieldPolicy.csv(links)
    }

    /// Accept/live_barter product ids. Historical `generateProductArray`
    /// skipped `xmoney` and `deleted` then appended `productId`. Nil IUO id
    /// becomes `""` so empty stubs still publish; nil status is not deleted.
    static func livePublishIds(from products: [HulaProduct]) -> [String] {
        var ids: [String] = []
        for product in products {
            if isCashChip(product.productId) || isDeleted(product.productStatus) {
                continue
            }
            ids.append(statusValue(product.productId))
        }
        return ids
    }
}

/// Seller inventory and feedback history listed `array[indexPath.row]` without
/// a bounds check. A reload that shrinks the list while a stale row is still
/// on screen crashed the seller sheet instead of skipping the cell or tap.
/// Product detail already soft-read NSDictionary rows; seller info did not.
struct DictionaryRowPolicy {
    static func dictionary(at index: Int, in rows: NSArray?) -> NSDictionary? {
        guard let rows = rows, index >= 0, index < rows.count else {
            return nil
        }
        return rows.object(at: index) as? NSDictionary
    }
}

/// Home/post/edit category tables, notifications list, and trade dashboard used
/// IUO `arrCategories.count` / `arrNotifications.count` / `arrCurrentTrades.count`.
/// A nil session array (cleared cache, partial init) must report 0 rows instead
/// of trapping before the first category, offer, or lobby room is shown.
struct SessionListPolicy {
    static func count(_ array: NSArray?) -> Int {
        return array?.count ?? 0
    }

    static func isEmpty(_ array: NSArray?) -> Bool {
        return count(array) == 0
    }

    static func hasItems(_ array: NSArray?) -> Bool {
        return count(array) > 0
    }

    static func count(_ trades: [NSDictionary]?) -> Int {
        return trades?.count ?? 0
    }

    static func isEmpty(_ trades: [NSDictionary]?) -> Bool {
        return count(trades) == 0
    }

    static func hasItems(_ trades: [NSDictionary]?) -> Bool {
        return count(trades) > 0
    }

    static func trades(_ trades: [NSDictionary]?) -> [NSDictionary] {
        return trades ?? []
    }

    /// Lobby room-cap used IUO `arrCurrentTrades.count >= maxTrades`.
    static func roomsFull(currentCount: Int, maxTrades: Int) -> Bool {
        return currentCount >= maxTrades
    }
}

/// Inventory blank-image thumbs read `dataManager.newProduct.arrProductPhotos`
/// instead of the row's product. An in-flight create draft must not paint every
/// listing with the draft camera roll (or crash on a nil draft album).
struct InventoryListingThumbPolicy {
    static func localFallbackPhoto(listingPhotos: NSArray?) -> UIImage? {
        return LocalPhotoAlbumPolicy.image(at: 0, in: listingPhotos)
    }
}

/// Dashboard, product modal, and barter asked
/// `onboardingTutorials.object(forKey:) as? String == nil` before the first tip.
/// That dictionary is an IUO filled only after UserData.plist loads, so a cold
/// start trapped on `.object(forKey:)`. Finishing a tip also `setObject`ed
/// `"done"` on the IUO, and `writeUserData` inserted it into the plist.
struct OnboardingTutorialPolicy {
    static let placeholderKey = "XInitializerItem"
    static let placeholderValue = "DoNotEverChangeMe"
    static let completedMarker = "done"

    /// Historical gate: show the tip when the stored value is not a String.
    /// A nil map, a missing key, NSNull, and numbers still show the tip.
    /// Any String, including `""` and `"done"`, counts as already recorded.
    static func shouldShow(named key: String, in tutorials: NSDictionary?) -> Bool {
        guard let tutorials = tutorials else {
            return true
        }
        return (tutorials.object(forKey: key) as? String) == nil
    }

    /// Plist write must never insert a nil object. A missing map becomes the
    /// same placeholder `loadUserData` uses when the key is absent.
    static func persistableDictionary(_ tutorials: NSDictionary?) -> NSMutableDictionary {
        if let tutorials = tutorials {
            return NSMutableDictionary(dictionary: tutorials)
        }
        let placeholder = NSMutableDictionary()
        placeholder.setObject(placeholderValue, forKey: placeholderKey as NSCopying)
        return placeholder
    }

    /// Record `"done"` without trapping on a nil dictionary. The input map is
    /// copied so an in-flight reader does not see a half-updated object.
    static func markingComplete(named key: String, in tutorials: NSDictionary?) -> NSMutableDictionary {
        let updated = persistableDictionary(tutorials)
        updated.setObject(completedMarker, forKey: key as NSCopying)
        return updated
    }
}
