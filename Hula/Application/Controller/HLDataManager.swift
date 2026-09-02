//
//  HLDataManager.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MapKit

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

class HLDataManager: NSObject {
    
    var currentUser: HulaUser!
    var newProduct: HulaProduct!
    var arrCategories : NSMutableArray!
    var arrTrades : [NSDictionary]! = []
    var arrCurrentTrades : [NSDictionary]! = []
    var arrPastTrades : [NSDictionary]! = []
    var arrNotifications : NSMutableArray!
    var uploadMode: Bool!
    var onboardingTutorials: NSMutableDictionary!
    var tradeMode:String = "current"
    var numNotificationsPending: Int = 0
    var lastServerMessage:String = ""
    var isLoadingNotifications:Bool = false
    var isInSwapVC : Bool = false
    var onlyLandscapeView : Bool = false
    
    let categoriesLoaded = Notification.Name("categoriesLoaded")
    let loginRecieved = Notification.Name("loginRecieved")
    let fbLoginRecieved = Notification.Name("fbLoginRecieved")
    let signupRecieved = Notification.Name("signupRecieved")
    let notificationsRecieved = Notification.Name("notificationsRecieved")
    
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
        numNotificationsPending = 0
        
        isInSwapVC = false
        
        arrCategories = []
        arrNotifications = []
        arrTrades = []
        arrCurrentTrades = []
        arrPastTrades = []
        getCategories()
//        arrCategories = [["icon" : "icon_cat_service" , "name" : "SERVICES"],
//                         ["icon" : "icon_cat_cars" , "name" : "CARS, BIKES & AUTO PARTS"],
//                         ["icon" : "icon_cat_clothing" , "name" : "CLOTHING"],
//                         ["icon" : "icon_cat_electronic" , "name" : "ELECTRONICS & MOBILE"],
//                         ["icon" : "icon_cat_furniture" , "name" : "FURNITURE"],
//                         ["icon" : "icon_cat_art" , "name" : "ART & ANTIQUES"],
//                         ["icon" : "icon_cat_house" , "name" : "HOUSE, YARD & FURNITURE"],
//                         ["icon" : "icon_cat_videogames" , "name" : "VIDEOGAMES"],
//                         ["icon" : "icon_cat_collectible" , "name" : "COLLECTIBLE & HOBBBIES"],
//                         ["icon" : "icon_cat_music" , "name" : "MUSIC & MUSICAL INSTRUMENTS"],
//                         ["icon" : "icon_cat_tool" , "name" : "TOOLS & REPAIR"],
//                         ["icon" : "icon_cat_photography" , "name" : "PHOTOGRAPHY"],
//                         ["icon" : "icon_cat_computer" , "name" : "COMPUTERS"],
//                         ["icon" : "icon_cat_sport" , "name" : "SPORTS"],
//                         ["icon" : "icon_cat_jewelry" , "name" : "JEWELRY"],
//                         ["icon" : "icon_cat_camping" , "name" : "CAMPING, SURVIVAL & OUTDOORS"],
//                         ["icon" : "icon_cat_other" , "name" : "OTHERS"]]
        
        
    }
    
    
    /// Categories list. Blank resource must not hit the API root.
    class func categoriesURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "categories")
    }

    /// Trades list GET / create POST without a trailing slash (`HulaTrade.saveNewTrade`).
    class func tradesCollectionURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "trades")
    }

    /// Email/password login. Blank resource must not POST to the API root.
    class func authenticateURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "authenticate")
    }

    /// Facebook login. Blank resource must not POST to the API root.
    class func facebookAuthURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "fbauth")
    }

    /// Signup. Blank resource must not POST to the API root.
    class func signupURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "signup")
    }

    /// Notifications list. Blank resource must not hit the API root.
    class func notificationsURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "notifications")
    }

    /// Login form body. `+`/`&`/`=` in email or password must not split fields.
    class func loginPostString(email: String, pass: String) -> String {
        return "email=" + CommonUtils.formEncodedValue(email)
            + "&pass=" + CommonUtils.formEncodedValue(pass)
    }

    /// Signup form body. Delimiters in email/nick/password must not split fields.
    class func signupPostString(email: String, nick: String, pass: String) -> String {
        return "email=" + CommonUtils.formEncodedValue(email)
            + "&pass=" + CommonUtils.formEncodedValue(pass)
            + "&name=" + CommonUtils.formEncodedValue(nick)
            + "&nick=" + CommonUtils.formEncodedValue(nick)
    }

    /// Facebook login form body.
    class func facebookAuthPostString(token: String) -> String {
        return "fbtoken=" + CommonUtils.formEncodedValue(token)
    }

    func getCategories() {
        guard let queryURL = HLDataManager.categoriesURL(apiBase: HulaConstants.apiURL) else {
            return
        }
        httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            if (ok){
                // Build off the shared array, then publish on the main thread.
                // Home/post/edit category tables read arrCategories on main while
                // this URLSession callback runs in the background.
                let categories = HLDataManager.categories(from: json)
                DispatchQueue.main.async {
                    self.arrCategories = categories
                    NotificationCenter.default.post(name: self.categoriesLoaded, object: nil)
                }
            }
        })
    }

    /// Parses category API payloads into a new array (no shared-state mutation).
    class func categories(from json: Any?) -> NSMutableArray {
        let categories = NSMutableArray()
        if let array = json as? [Any] {
            for cat in array {
                categories.add(cat)
            }
        }
        return categories
    }
    enum TradeDashboardBucket {
        case current
        case past
        case hidden
    }

    /// Classify a trade for the dashboard lists without mutating manager state.
    static func classifyTrade(
        status: String?,
        ownerId: String?,
        turnUserId: String?,
        viewerId: String,
        ownerAccepted: Bool?,
        otherAccepted: Bool?,
        otherAgree: Bool?
    ) -> TradeDashboardBucket {
        guard let st = status, let ownerId = ownerId else {
            return .hidden
        }

        var hideFromDashboard = false
        if ownerId == viewerId {
            if ownerAccepted == true {
                hideFromDashboard = true
            }
        } else {
            if otherAccepted == true {
                hideFromDashboard = true
            }
            if otherAgree == false {
                hideFromDashboard = true
            }
        }

        if st != HulaConstants.end_status && st != HulaConstants.cancel_status && !hideFromDashboard {
            if st != HulaConstants.pending_status || turnUserId == viewerId {
                return .current
            }
            return .hidden
        }

        if st == HulaConstants.end_status || st == HulaConstants.review_status {
            return .past
        }
        return .hidden
    }

    /// Pure categorization used by `getTrades` so trade lists can be rebuilt
    /// without mutating the shared arrays until a main-thread publish.
    /// Soft-parses Bool/0/1 acceptance flags so JSON bridges do not mis-bucket rooms.
    class func partitionTrades(_ array: [NSDictionary], userId: String) -> (all: [NSDictionary], current: [NSDictionary], past: [NSDictionary]) {
        var all: [NSDictionary] = []
        var current: [NSDictionary] = []
        var past: [NSDictionary] = []
        for trade in array {
            all.append(trade)
            let bucket = classifyTrade(
                status: trade.object(forKey: "status") as? String,
                ownerId: trade.object(forKey: "owner_id") as? String,
                turnUserId: trade.object(forKey: "turn_user_id") as? String,
                viewerId: userId,
                ownerAccepted: CommonUtils.boolFromJSON(trade.object(forKey: "owner_accepted")),
                otherAccepted: CommonUtils.boolFromJSON(trade.object(forKey: "other_accepted")),
                otherAgree: CommonUtils.boolFromJSON(trade.object(forKey: "other_agree"))
            )
            switch bucket {
            case .current:
                current.append(trade)
            case .past:
                past.append(trade)
            case .hidden:
                break
            }
        }
        return (all, current, past)
    }

    /// Optional credentials that must survive UserData.plist cold-start round-trips.
    class func userSessionCredentialSnapshot(from user: HulaUser) -> [String: String] {
        return [
            "zip": user.zip ?? "",
            "fbToken": user.fbToken ?? "",
            "twToken": user.twToken ?? "",
            "liToken": user.liToken ?? "",
            "deviceId": user.deviceId ?? "",
            "status": user.status ?? ""
        ]
    }

    /// Restore optional credentials from plist/API payloads (including alternate key names).
    class func applyUserSessionCredentials(to user: HulaUser, from dict: NSDictionary) {
        if let zip = dict.object(forKey: "zip") as? String {
            user.zip = zip
        }
        if let status = dict.object(forKey: "status") as? String {
            user.status = status
        }
        if let fb = dict.object(forKey: "fbToken") as? String {
            user.fbToken = fb
        }
        if let fb = dict.object(forKey: "fb_token") as? String {
            user.fbToken = fb
        }
        if let fb = dict.object(forKey: "fbtoken") as? String {
            user.fbToken = fb
        }
        if let tw = dict.object(forKey: "twToken") as? String {
            user.twToken = tw
        }
        if let tw = dict.object(forKey: "tw_token") as? String {
            user.twToken = tw
        }
        if let tw = dict.object(forKey: "twtoken") as? String {
            user.twToken = tw
        }
        if let li = dict.object(forKey: "liToken") as? String {
            user.liToken = li
        }
        if let li = dict.object(forKey: "li_token") as? String {
            user.liToken = li
        }
        if let li = dict.object(forKey: "litoken") as? String {
            user.liToken = li
        }
        if let device = dict.object(forKey: "deviceId") as? String {
            user.deviceId = device
        }
        if let device = dict.object(forKey: "push_device_id") as? String {
            user.deviceId = device
        }
    }

    /// After `logout()` clears fbToken, keep the login token when the profile payload omitted it.
    class func resolvedFacebookToken(currentFbToken: String, loginToken: String) -> String {
        if currentFbToken.count > 0 {
            return currentFbToken
        }
        return loginToken
    }

    func getTrades(taskCallback: @escaping (Bool) -> ()) {
        guard let queryURL = HLDataManager.tradesCollectionURL(apiBase: HulaConstants.apiURL) else {
            DispatchQueue.main.async {
                taskCallback(false)
            }
            return
        }
        httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            if (ok){
                // Build replacements off the shared arrays, then publish on the main
                // thread. URLSession callbacks run in the background; clearing
                // arrCurrentTrades there races with myRoomsFull / amITradingWith /
                // dashboard copies and can bypass the room cap or crash.
                let array = json as? [NSDictionary] ?? []
                let viewerId = HulaUser.sharedInstance.userId ?? ""
                let partitioned = HLDataManager.partitionTrades(array, userId: viewerId)
                DispatchQueue.main.async {
                    self.arrTrades = partitioned.all
                    self.arrCurrentTrades = partitioned.current
                    self.arrPastTrades = partitioned.past
                    taskCallback(true)
                }
            } else {
                DispatchQueue.main.async {
                    taskCallback(false)
                }
            }
        })
    }
    
    func ga(_ page: String){
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: page)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    /// Email login observers wait on `loginRecieved`. Transport failures must still
    /// publish a string so the login UI is not left spinning.
    class func publishedEmailLoginResult(httpOk: Bool, parsed: String) -> String {
        if httpOk {
            return parsed
        }
        return NSLocalizedString("Connection error. Please try again.", comment: "")
    }

    /// Facebook/signup observers wait on a Bool. Transport failures must publish false.
    class func publishedBoolAuthResult(httpOk: Bool, parsed: Bool) -> Bool {
        return httpOk && parsed
    }
    
    func loginUser(email:String, pass:String) {
        
        //print("Login in progress...")
        guard let queryURL = HLDataManager.authenticateURL(apiBase: HulaConstants.apiURL) else {
            self.lastServerMessage = HLDataManager.publishedEmailLoginResult(httpOk: false, parsed: "")
            NotificationCenter.default.post(name: self.loginRecieved, object: self.lastServerMessage)
            return
        }
        var loginSuccess = "";
        let postString = HLDataManager.loginPostString(email: email, pass: pass)
        httpPost(urlstr: queryURL, postString: postString, isPut: false, taskCallback: { (ok, json) in
            
            //print("done")
            //print(ok)
            //print(json!)
            if (ok){
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    if (dictionary["token"] as? String) != nil {
                        // Clear any prior in-memory session before applying auth fields.
                        // Without this, a re-login after token-expiry (which does not call
                        // logout) can leave the previous account's profile fields in place
                        // and later full-object PUTs write them onto the new account.
                        HulaUser.sharedInstance.logout()
                        // access individual value in dictionary
                        
                        self.updateUserFromDict(dict: dictionary as NSDictionary)
                        //user.token = token
                        //user.userId = dictionary["userId"] as? String
                        //print(token)
                        loginSuccess = "ok";
                        self.writeUserData()
                    }
                    if let resp = dictionary["message"] as? String {
                        loginSuccess = resp;
                    }
                } else {
                    user.token = ""
                    loginSuccess = NSLocalizedString("Incorrect login. Please try again.", comment: "");
                }
            }
            self.lastServerMessage = HLDataManager.publishedEmailLoginResult(httpOk: ok, parsed: loginSuccess)
            NotificationCenter.default.post(name: self.loginRecieved, object: self.lastServerMessage)
        })
    }
    
    func loginUserWithFacebook(token:String){
        guard let queryURL = HLDataManager.facebookAuthURL(apiBase: HulaConstants.apiURL) else {
            NotificationCenter.default.post(
                name: self.fbLoginRecieved,
                object: HLDataManager.publishedBoolAuthResult(httpOk: false, parsed: false)
            )
            return
        }
        var loginSuccess = false;
        
        httpPost(urlstr: queryURL, postString: HLDataManager.facebookAuthPostString(token: token), isPut: false, taskCallback: { (ok, json) in
            
            //print("done")
            //print(ok)
            //print(json!)
            self.lastServerMessage = NSLocalizedString("Facebook login error", comment: "")
            if (ok){
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    if (dictionary["token"] as? String) != nil {
                        
                        if let us = dictionary["allUser"] as? NSDictionary {
                            // Preserve the FB access token across logout(); logout() clears
                            // fbToken and updateUserFromDict historically did not restore
                            // fb_token / fbtoken from allUser, so the subsequent welcome-screen
                            // push registration PUT would wipe the just-saved server fbtoken.
                            let preservedFbToken = token
                            HulaUser.sharedInstance.logout();
                            //print(us)
                            // access individual value in dictionary
                            
                            self.updateUserFromDict(dict: dictionary as NSDictionary)
                            self.updateUserFromDict(dict: us as NSDictionary)
                            HulaUser.sharedInstance.fbToken = HLDataManager.resolvedFacebookToken(
                                currentFbToken: HulaUser.sharedInstance.fbToken ?? "",
                                loginToken: preservedFbToken
                            )
                            //print(token)
                            self.writeUserData()
                        }
                        loginSuccess = true;
                        self.lastServerMessage = "ok"
                    }
                } else {
                    user.token = ""
                }
            }
            NotificationCenter.default.post(
                name: self.fbLoginRecieved,
                object: HLDataManager.publishedBoolAuthResult(httpOk: ok, parsed: loginSuccess)
            )
        })
 
    }

    
    func logout() {
        //var user = HulaUser.sharedInstance
        HulaUser.sharedInstance.token = ""
        HulaUser.sharedInstance.userId = ""
        
        HulaUser.sharedInstance.logout();
        clearSessionCaches()
        self.writeUserData()
        
        
    }

    /// Drops in-memory session lists so a later logged-out UI path cannot show
    /// the previous account's trades/notifications.
    func clearSessionCaches() {
        arrTrades = []
        arrCurrentTrades = []
        arrPastTrades = []
        arrNotifications = []
        numNotificationsPending = 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        isLoadingNotifications = false
        isInSwapVC = false
    }
    
    func amITradingWith(_ user_id: String) -> Bool{
        for tr in arrCurrentTrades{
            if let trade = tr as? [String:Any] {
                if let owner = trade["owner_id"] as? String, owner == user_id {
                    return true
                }
                if let other = trade["other_id"] as? String, other == user_id {
                    return true
                }
            }
        }
        return false
    }
    
    func getTradeWith(_ user_id: String) -> String{
        return PendingOfferPolicy.tradeId(
            withUser: user_id,
            currentUserId: HulaUser.sharedInstance.userId ?? "",
            currentTrades: arrCurrentTrades ?? [],
            allTrades: arrTrades ?? [])
    }
    func amIOfferedToTradeWith(_ user_id: String) -> Bool{
        return PendingOfferPolicy.isOffered(
            withUser: user_id,
            currentUserId: HulaUser.sharedInstance.userId ?? "",
            currentTrades: arrCurrentTrades ?? [],
            allTrades: arrTrades ?? [])
    }
    
    /// Seller Options → "Trade with this user" must not appear (or POST) while already
    /// trading or while a pending inbound offer still needs Accept/Decline.
    class func shouldOfferStartTradeAction(tradingWith: Bool, pendingInboundOffer: Bool) -> Bool {
        return !tradingWith && !pendingInboundOffer
    }

    func myRoomsFull() -> Bool{
        if (arrCurrentTrades.count >= HulaUser.sharedInstance.maxTrades){
            return true
        }
        return false
    }
    
    func signupUser(email:String, nick: String, pass:String) {
        
        //print("Login in progress...")
        guard let queryURL = HLDataManager.signupURL(apiBase: HulaConstants.apiURL) else {
            NotificationCenter.default.post(
                name: self.signupRecieved,
                object: HLDataManager.publishedBoolAuthResult(httpOk: false, parsed: false)
            )
            return
        }
        var signupSuccess = false;
        let postString = HLDataManager.signupPostString(email: email, nick: nick, pass: pass)
        httpPost(urlstr: queryURL, postString: postString, isPut: false, taskCallback: { (ok, json) in
            
            //print("done")
            //print(ok)
            if (ok){
                //print(json!)
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    // access individual value in dictionary
                    if let token = dictionary["token"] as? String {
                        if (token != ""){
                            self.updateUserFromDict(dict: dictionary as NSDictionary)
                            //print(token)
                            signupSuccess = true;
                            self.writeUserData()
                            self.lastServerMessage = "ok"
                        } else {
                            
                            self.lastServerMessage = NSLocalizedString("User email already exists! Please use the login form.", comment: "")
                            
                        }
                        
                    }
                } else {
                    user.token = ""
                    self.lastServerMessage = NSLocalizedString("Server response unexpected", comment: "")
                }
            }
            NotificationCenter.default.post(
                name: self.signupRecieved,
                object: HLDataManager.publishedBoolAuthResult(httpOk: ok, parsed: signupSuccess)
            )
        })
    }
    
    
    func getUserProfile(userId:String, taskCallback: @escaping (HulaUser, NSArray, NSArray) -> ()) {
        //print("Getting user info...")
        guard let queryURL = HLDataManager.userProfileURL(apiBase: HulaConstants.apiURL, userId: userId) else {
            return
        }
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        let userReturned = HulaUser()
                        //print("----------- User loaded")
                        //print(dictionary)
                        if let user = dictionary["user"] as? NSDictionary {
                            userReturned.populate(with: user)
                        }
                        var arrProducts = NSArray()
                        if let dpr = dictionary["products"] as? NSArray {
                            arrProducts = dpr
                        }
                        var arrFeedback = NSArray()
                        if let dpr = dictionary["feedback"] as? NSArray {
                            arrFeedback = dpr
                        }
                        taskCallback(userReturned, arrProducts, arrFeedback)
                    }
                }
            } else {
                // connection error
            }
        })
    }
    
    func getProduct(productId:String, taskCallback: @escaping (HulaProduct) -> ()) {
        //print("Getting user info...")
        guard let queryURL = HLDataManager.productURL(apiBase: HulaConstants.apiURL, productId: productId) else {
            return
        }
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? NSDictionary {
                        let productReturned = HulaProduct()
                        productReturned.populate(with: dictionary)
                        taskCallback(productReturned)
                    }
                }
            } else {
                // connection error
            }
        })
    }
    
    
    /// Product GET. Blank/unencodable productId must not hit `products/`.
    class func productURL(apiBase: String, productId: String?) -> String? {
        return CommonUtils.productResourceURL(apiBase: apiBase, productId: productId)
    }

    /// User profile GET. Blank/unencodable userId must not hit `users/`.
    class func userProfileURL(apiBase: String, userId: String?) -> String? {
        return CommonUtils.userResourceURL(apiBase: apiBase, userId: userId)
    }

    /// Soft-parse a network body. HTML/empty/invalid payloads must not crash via `try!`.
    class func jsonObject(from data: Data) -> Any? {
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }

    /// Upload endpoints used `URL(string:)!`. Blank/malformed bases must skip the request.
    class func uploadRequestURL(apiBase: String, resource: String?) -> URL? {
        guard let urlstr = CommonUtils.apiResourceURL(apiBase: apiBase, path: ["upload", resource]) else {
            return nil
        }
        return URL(string: urlstr)
    }

    func httpGet(urlstr:String, taskCallback: @escaping (Bool, Any?) -> ()) {
        guard let url = URL(string: urlstr) else {
            taskCallback(false, nil)
            return
        }
        //print(url)
        var request:URLRequest = URLRequest(url: url)
        
        let user = HulaUser.sharedInstance
        //print(user.token)
        if (user.token.count>10){
            request.setValue(user.token, forHTTPHeaderField: "x-access-token")
        }
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                taskCallback(false, nil)
                return
            }
            guard let data = data else {
                print("Data is empty")
                taskCallback(false, nil)
                return
            }
            //print(request)
            //print(response)
            //print(data.count)
            guard let json = HLDataManager.jsonObject(from: data) else {
                taskCallback(false, nil)
                return
            }
            //print(json)
            taskCallback(true, json as AnyObject?)
        }
    
        task.resume()
    }

    func httpPost(urlstr:String, postString:String, isPut: Bool, taskCallback: @escaping (Bool, Any?) -> ()) {
        guard let url = URL(string: urlstr) else {
            taskCallback(false, nil)
            return
        }
        var request = URLRequest(url: url)
        if (isPut){
            request.httpMethod = "PUT"
        } else {
            request.httpMethod = "POST"
        }
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") //Optional
        request.httpBody = postString.data(using: .utf8)
        let user = HulaUser.sharedInstance
        if (user.token.count>10){
            request.addValue(user.token, forHTTPHeaderField: "x-access-token")
        }
        //print(request.httpBody!)
        //print(request.httpMethod!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                if let error = error {
                    print(error)
                }
                taskCallback(false, nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response ?? "No response")
            }
            guard let json = HLDataManager.jsonObject(from: data) else {
                taskCallback(false, nil)
                return
            }
            taskCallback(true, json as AnyObject?)
        }
        task.resume()
    }
    
    func uploadImage(_ image: UIImage, itemPosition: Int, taskCallback: @escaping (Bool, Any?) -> ()){
        let imageData = UIImageJPEGRepresentation(image,0.7)
        
        if imageData != nil{
            guard let url = HLDataManager.uploadRequestURL(apiBase: HulaConstants.apiURL, resource: "image") else {
                taskCallback(false, nil)
                return
            }
            var request = URLRequest(url: url)
            let session:URLSession = URLSession.shared
            
            request.httpMethod = "POST"
            
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let user = HulaUser.sharedInstance
            if (user.token.count>10){
                request.setValue(user.token, forHTTPHeaderField: "x-access-token")
            }
            let body = createBody(parameters: ["position": "\(itemPosition)"],
                                  boundary: boundary,
                                  data: imageData!,
                                  mimeType: "image/jpeg",
                                  filename: "image1.jpg")
            
            
            request.httpBody = body as Data
            
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    if let error = error {
                        print(error)
                    }
                    taskCallback(false, nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print(response ?? "No response")
                    taskCallback(false, nil)
                } else {
                    guard let json = HLDataManager.jsonObject(from: data) else {
                        taskCallback(false, nil)
                        return
                    }
                    taskCallback(true, json as AnyObject?)
                }
            }
            task.resume()
            
        }
    }
    
    func uploadVideo(_ videoPath: String, productId:String, tradeId:String, taskCallback: @escaping (Bool, Any?) -> ()){
        let videoData = NSData(contentsOfFile: videoPath)
        
        if videoData != nil{
            guard let url = HLDataManager.uploadRequestURL(apiBase: HulaConstants.apiURL, resource: "video") else {
                taskCallback(false, nil)
                return
            }
            var request = URLRequest(url: url)
            let session:URLSession = URLSession.shared
            
            request.httpMethod = "POST"
            
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let user = HulaUser.sharedInstance
            if (user.token.count>10){
                request.setValue(user.token, forHTTPHeaderField: "x-access-token")
            }
            let body = createBody(parameters: ["product_id": "\(productId)", "trade_id": "\(tradeId)"],
                                  boundary: boundary,
                                  data: videoData! as Data,
                                  mimeType: "video/mp4",
                                  filename: "video.mp4")
            
            
            request.httpBody = body as Data
            
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    if let error = error {
                        print(error)
                    }
                    taskCallback(false, nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print(response ?? "No response")
                    taskCallback(false, nil)
                } else {
                    guard let json = HLDataManager.jsonObject(from: data) else {
                        taskCallback(false, nil)
                        return
                    }
                    taskCallback(true, json as AnyObject?)
                }
            }
            task.resume()
            
        }
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        //print(body)
        return body as Data
    }
    
    
    func writeUserData(){
        guard let path = CommonUtils.sessionFilePath(
            fileName: HulaConstants.userFile + ".plist"
        ) else {
            return
        }
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        //saving values
        
        let user = HulaUser.sharedInstance
        
        dict.setObject(user.token, forKey: "token" as NSCopying)
        dict.setObject(user.userId, forKey: "userId" as NSCopying)
        dict.setObject(user.userNick, forKey: "userNick" as NSCopying)
        dict.setObject(user.userName, forKey: "userName" as NSCopying)
        dict.setObject(user.userEmail, forKey: "userEmail" as NSCopying)
        dict.setObject(user.maxTrades, forKey: "max_trades" as NSCopying)
        dict.setObject(user.userLocationName, forKey: "userLocationName" as NSCopying)
        dict.setObject(self.onboardingTutorials, forKey: "onboardingTutorials" as NSCopying)
        dict.setObject([CGFloat(user.location.coordinate.latitude), CGFloat(user.location.coordinate.longitude)] as [CGFloat], forKey: "userLocation" as NSCopying)
        dict.setObject(user.userPhotoURL, forKey: "userPhotoURL" as NSCopying)
        dict.setObject(user.userBio, forKey: "userBio" as NSCopying)
        dict.setObject(user.numProducts, forKey: "numProducts" as NSCopying)
        // Persist optional credentials so cold start / welcome push PUTs do not wipe
        // server-side zip, social tokens, or push device id (see getPostString omission).
        let credentials = HLDataManager.userSessionCredentialSnapshot(from: user)
        for (key, value) in credentials {
            dict.setObject(value, forKey: key as NSCopying)
        }
        
        //...
        dict.write(toFile: path, atomically: false)
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("Saved UserData.plist file is --> \(String(describing: resultDictionary?.description))")
        
        self.loadUserData()
    }
    
    
    public func loadUserData() {
        // getting path to GameData.plist
        guard let path = CommonUtils.sessionFilePath(
            fileName: HulaConstants.userFile + ".plist"
        ) else {
            return
        }
        
        //        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        let fileManager = FileManager.default
        
        //check if file exists
        if(!fileManager.fileExists(atPath: path))
        {
            // If it doesn't, copy it from the default file in the Bundle
            
            if let bundlePath = Bundle.main.path(forResource: HulaConstants.userFile, ofType: "plist")
            {
                //let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                //print("Bundle UserData.plist file is --> \(String(describing: resultDictionary?.description))")
                
                do
                {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                    //print("copy")
                }
                catch _
                {
                    print("error failed loading data")
                }
            }
            else
            {
                print("UserData.plist not found. Please, make sure it is part of the bundle.")
            }
        }
        else
        {
            //print("UserData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("Loaded UserData.plist file is --> \(String(describing: resultDictionary?.description))")
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            //loading values
            
            //print("User data loaded:")
            //print(dict)
            
            updateUserFromDict(dict: dict)
            if let tmp = dict.object(forKey: "onboardingTutorials") as? NSDictionary {
                let tmpMutable:NSMutableDictionary = NSMutableDictionary(dictionary: tmp)
                self.onboardingTutorials = tmpMutable
            } else {
                self.onboardingTutorials = ["XInitializerItem": "DoNotEverChangeMe"]
            }
            
            self.loadUserNotifications()
        } else {
            print("WARNING: Couldn't create dictionary from UserData.plist! Default values will be used!")
        }
        //self.onboardingTutorials = ["XInitializerItem": "DoNotEverChangeMe"]
        //print (self.onboardingTutorials)
    }//eom
    
    /// First non-empty string among alternate API/plist keys. Avoids force-casts
    /// when restoring session fields from cold-start dictionaries.
    class func stringField(_ dict: NSDictionary, keys: [String]) -> String? {
        for key in keys {
            if let value = dict.object(forKey: key) as? String {
                return value
            }
        }
        return nil
    }

    func updateUserFromDict(dict: NSDictionary){
        let user = HulaUser.sharedInstance
        if let token = HLDataManager.stringField(dict, keys: ["token"]) {
            user.token = token
        }
        if let userId = HLDataManager.stringField(dict, keys: ["userId", "_id"]) {
            user.userId = userId
        }
        if let nick = HLDataManager.stringField(dict, keys: ["userNick", "nick"]) {
            user.userNick = nick
        }
        if let name = HLDataManager.stringField(dict, keys: ["userName", "name"]) {
            user.userName = name
        }
        if let email = HLDataManager.stringField(dict, keys: ["userEmail", "email"]) {
            user.userEmail = email
        }
        if let bio = HLDataManager.stringField(dict, keys: ["userBio", "bio"]) {
            user.userBio = bio
        }
        if let photo = HLDataManager.stringField(dict, keys: ["userPhotoURL", "image"]) {
            user.userPhotoURL = photo
        }
        if let locationName = HLDataManager.stringField(dict, keys: ["userLocationName", "location_name"]) {
            user.userLocationName = locationName
        }
        // Soft-parse across Int/Double/NSNumber; reject Bool so true never becomes max_trades=1.
        if let maxTrades = CommonUtils.intFromJSON(dict.object(forKey: "max_trades")) {
            user.maxTrades = maxTrades
        }
        // Soft-parse session/API location arrays. `as? [CGFloat]` drops NSNumber-bridged
        // plist/JSON coords and leaves the user at (0,0) after relaunch/login.
        if let loc = CommonUtils.location(fromJSON: dict.object(forKey: "userLocation"))
            ?? CommonUtils.location(fromJSON: dict.object(forKey: "location")) {
            user.location = loc
        }
        if let n = CommonUtils.intFromJSON(dict.object(forKey: "numProducts")) {
            user.numProducts = n
        }
        HLDataManager.applyUserSessionCredentials(to: user, from: dict)
    }
    
    /// Bounds-safe notification lookup for Accept/Reject and row actions.
    /// Stale cell tags after a background refresh must not NSRangeException.
    func notification(at index: Int) -> NSDictionary? {
        guard index >= 0 && index < arrNotifications.count else { return nil }
        return arrNotifications.object(at: index) as? NSDictionary
    }

    /// Build notification list + unread badge count without mutating shared state.
    /// Soft-parses bridged `is_read` 0/1 via intFromJSON; skips deleted rows for both list and badge.
    class func notificationsPayload(from json: Any?) -> (items: NSMutableArray, pending: Int) {
        let items = NSMutableArray()
        var pending = 0
        if let array = json as? [Any] {
            for not in array {
                if let dict = not as? [String: Any] {
                    guard let status = dict["status"] as? String, status != "deleted" else {
                        continue
                    }
                    items.add(not)
                    if CommonUtils.intFromJSON(dict["is_read"]) == 0 {
                        pending += 1
                    }
                }
            }
        }
        return (items, pending)
    }

    /// Loading flag must always clear after a response, including transport failures.
    /// Otherwise Notifications VC's checkIfNotificationsLoaded reschedules forever.
    class func isLoadingNotifications(afterResponseReceived ok: Bool) -> Bool {
        return false
    }

    func loadUserNotifications(){
        //print("loading notifications...")
        if HulaUser.sharedInstance.isUserLoggedIn() {
            isLoadingNotifications = true
            guard let queryURL = HLDataManager.notificationsURL(apiBase: HulaConstants.apiURL) else {
                isLoadingNotifications = HLDataManager.isLoadingNotifications(afterResponseReceived: false)
                NotificationCenter.default.post(name: self.notificationsRecieved, object: nil)
                return
            }
            httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(ok)
                if (ok){
                    let payload = HLDataManager.notificationsPayload(from: json)
                    DispatchQueue.main.async {
                        self.arrNotifications = payload.items
                        HLDataManager.sharedInstance.numNotificationsPending = payload.pending
                        UIApplication.shared.applicationIconBadgeNumber = payload.pending
                        self.isLoadingNotifications = HLDataManager.isLoadingNotifications(afterResponseReceived: true)
                        NotificationCenter.default.post(name: self.notificationsRecieved, object: nil)
                    }
                } else {
                    // Transport / server failure: clear the loading flag so UI polling stops.
                    DispatchQueue.main.async {
                        self.isLoadingNotifications = HLDataManager.isLoadingNotifications(afterResponseReceived: false)
                        NotificationCenter.default.post(name: self.notificationsRecieved, object: nil)
                    }
                }
            })
        } else {
            HLDataManager.sharedInstance.numNotificationsPending = 0
            UIApplication.shared.applicationIconBadgeNumber = 0
            self.isLoadingNotifications = false
            self.arrNotifications = []
            NotificationCenter.default.post(name: self.notificationsRecieved, object: nil)
        }
    }
}
