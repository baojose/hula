//
//  CommonUtils.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class CommonUtils: NSObject {
    
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

    func loadImageOnView(imageView:UIImageView, withURL:String){
        let urlString = withURL
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Failed fetching image:", error!)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                return
            }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
            }
            }.resume()
    }
    
    func getDistanceFrom(lat:CGFloat, lon:CGFloat) -> String{
        let coordinate₀ = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        
        return getDistanceFrom(loc:coordinate₀)
    }
    func getDistanceFrom(loc:CLLocation) -> String{
        let coordinate₀ = loc
        
        if let userLocation = HulaUser.sharedInstance.location {
            let distanceInMeters = coordinate₀.distance(from: userLocation) // result is in meters
            
            var distance = round( distanceInMeters / 1609 )
            if (distance<1){
                distance = round( distanceInMeters / 161 ) / 10
            } else {
                if (distance>100){
                    distance = 999
                    return "Too far"
                }
            }
            return "\(distance) miles"
        } else {
            return "-"
        }
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
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
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
    func userImageURL(userId: String) -> String{
        return HulaConstants.apiURL + "users/\(userId)/image"
    }
    func productImageURL(productId: String) -> String{
        return HulaConstants.apiURL + "products/\(productId)/image"
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
    func loadImageFromURL(urlString: String) {
        self.image = nil
        
        // check for cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            //print("getting: \(urlString)")
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
                    imageCache.setObject(image!, forKey: urlString as AnyObject)
                }
            })
            
        }).resume()
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
