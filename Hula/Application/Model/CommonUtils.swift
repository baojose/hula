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
    func cropImage(_ image: UIImage!, _ newSize: CGSize!) -> UIImage{
        let ratio: Double!
        let delta: Double!
        let offset: CGPoint!
        
        let hRatio: Double! = Double(newSize.width / image.size.width)
        let vRatio: Double! = Double(newSize.height / image.size.height)
        
        if hRatio > vRatio {
            ratio = hRatio
            delta = Double(CGFloat(ratio) * image.size.height - newSize.height)
            offset = CGPoint(x: 0.0, y: delta / 2)
        }else{
            ratio = vRatio
            delta = Double(CGFloat(ratio) * image.size.width - newSize.width)
            offset = CGPoint(x: delta / 2, y: 0.0)
        }
        let cropArea: CGRect = CGRect(x: -offset.x, y: -offset.y, width: CGFloat(ratio) * image.size.width, height: CGFloat(ratio) * image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        UIRectClip(cropArea)
        image.draw(in: cropArea)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage!
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
    func getDistanceFrom(loc:CLLocation) -> String{
        let coordinate₀ = loc
        
        if loc.coordinate.latitude == 0 && loc.coordinate.longitude == 0 {
            return "-"
        }
        if HulaUser.sharedInstance.location.coordinate.latitude == 0 && HulaUser.sharedInstance.location.coordinate.longitude == 0 {
            return "-"
        }
        if let userLocation = HulaUser.sharedInstance.location {
            let distanceInMeters = coordinate₀.distance(from: userLocation) // result is in meters
            
            var distance = round( distanceInMeters / 1609 );
            var dist_unit = NSLocalizedString("miles", comment: "");
            if (!inUSA(HulaUser.sharedInstance.location)){
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
        } else {
            return "-"
        }
    }
    func inUSA(_ loc:CLLocation) -> Bool{
        if (loc.coordinate.longitude < -50) && (loc.coordinate.longitude > -170){
            return true
        }
        return false;
    }
    func getCGDistanceFrom(loc:CLLocation) -> CGFloat{
        if let userLocation = HulaUser.sharedInstance.location {
            let distanceInMeters:CGFloat = CGFloat(loc.distance(from: userLocation)) // result is in meters
            return distanceInMeters  / 1609.0
        } else {
            return CGFloat(0.0)
        }
    }
    
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) " + NSLocalizedString("years ago", comment: "")
        } else if (components.year! >= 1){
            if (numericDates){
                return NSLocalizedString("1 year ago", comment: "")
            } else {
                return NSLocalizedString("Last year", comment: "")
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) " + NSLocalizedString("months ago", comment: "")
        } else if (components.month! >= 1){
            if (numericDates){
                return NSLocalizedString("1 month ago", comment: "")
            } else {
                return NSLocalizedString("Last month", comment: "")
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) " + NSLocalizedString("weeks ago", comment: "")
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return NSLocalizedString("1 week ago", comment: "")
            } else {
                return NSLocalizedString("Last week", comment: "")
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) " + NSLocalizedString("days ago", comment: "")
        } else if (components.day! >= 1){
            if (numericDates){
                return NSLocalizedString("1 day ago", comment: "")
            } else {
                return NSLocalizedString("Yesterday", comment: "")
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) " + NSLocalizedString("hours ago", comment: "")
        } else if (components.hour! >= 1){
            if (numericDates){
                return NSLocalizedString("1 hour ago", comment: "")
            } else {
                return NSLocalizedString("An hour ago", comment: "")
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) " + NSLocalizedString("minutes ago", comment: "")
        } else if (components.minute! >= 1){
            if (numericDates){
                return NSLocalizedString("1 minute ago", comment: "")
            } else {
                return NSLocalizedString("A minute ago", comment: "")
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago" + NSLocalizedString("seconds ago", comment: "")
        } else {
            return NSLocalizedString("Just now", comment: "")
        }
        
    }
    
    func isoDateToNSDate(date:String) -> NSDate{
        //print(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        let dateObj = dateFormatter.date(from: date)
        if (dateObj != nil){
            return dateObj! as NSDate
        } else {
            return NSDate()
        }
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
                    
                    HLDataManager.sharedInstance.onboardingTutorials.setObject("done", forKey: self.tutorialToComplete as NSCopying)
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
            
            HLDataManager.sharedInstance.onboardingTutorials.setObject("done", forKey: self.tutorialToComplete as NSCopying)
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
