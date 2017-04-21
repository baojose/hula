//
//  HLDataManager.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit



class HLDataManager: NSObject {
    
    var currentUser: HulaUser!
    var newProduct: HulaProduct!
    var arrCategories : NSMutableArray!
    var arrNotifications : NSMutableArray!
    var uploadMode: Bool!
    
    let categoriesLoaded = Notification.Name("categoriesLoaded")
    let loginRecieved = Notification.Name("loginRecieved")
    let signupRecieved = Notification.Name("signupRecieved")
    
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
        
        
        arrCategories = []
        arrNotifications = []
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
        
        loadUserData()
    }
    
    
    func getCategories() {
        let queryURL = HulaConstants.apiURL + "categories"
        httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            print(ok)
            if (ok){
                self.arrCategories=[];
                if let array = json as? [Any] {
                    for cat in array {
                        // access all objects in array
                        self.arrCategories.add(cat)
                    }
                }
                
                NotificationCenter.default.post(name: self.categoriesLoaded, object: nil)
            }
        })
    }
    
    func loginUser(email:String, pass:String) {
        
        //print("Login in progress...")
        let queryURL = HulaConstants.apiURL + "authenticate"
        var loginSuccess = false;
        httpPost(urlstr: queryURL, postString: "email="+email+"&pass="+pass, taskCallback: { (ok, json) in
            
            print("done")
            print(ok)
            print(json!)
            if (ok){
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    if let token = dictionary["token"] as? String {
                        // access individual value in dictionary
                        user.token = token
                        user.userId = dictionary["userId"] as? String
                        print(token)
                        loginSuccess = true;
                        self.writeUserData()
                    }
                } else {
                    user.token = ""
                }
                
                NotificationCenter.default.post(name: self.loginRecieved, object: loginSuccess)
            }
        })
    }
    

    
    func logout() {
        let user = HulaUser.sharedInstance
        user.token = ""
        user.userId = ""
        self.writeUserData()
    }
    
    func signupUser(email:String, nick: String, pass:String) {
        
        //print("Login in progress...")
        let queryURL = HulaConstants.apiURL + "signup"
        var signupSuccess = false;
        httpPost(urlstr: queryURL, postString: "email="+email+"&pass="+pass+"&name="+nick+"&nick="+nick, taskCallback: { (ok, json) in
            
            print("done")
            print(ok)
            if (ok){
                //print(json!)
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    if let token = dictionary["token"] as? String {
                        // access individual value in dictionary
                        user.token = token
                        user.userId = dictionary["userId"] as? String
                        print(token)
                        signupSuccess = true;
                        self.writeUserData()
                    }
                } else {
                    user.token = ""
                }
                
                NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
            }
        })
    }
    
    func httpGet(urlstr:String, taskCallback: @escaping (Bool, Any?) -> ()) {
        let url = URL(string: urlstr)
        var request:URLRequest = URLRequest(url: url!)
        
        let user = HulaUser.sharedInstance
        //print(user.token)
        if (user.token.characters.count>10){
            request.setValue(user.token, forHTTPHeaderField: "x-access-token")
        }
        request.httpMethod = "GET"
        //print(request)
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
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            taskCallback(true, json as AnyObject?)
        }
    
        task.resume()
    }

    func httpPost(urlstr:String, postString:String, taskCallback: @escaping (Bool, Any?) -> ()) {
        let url = URL(string: urlstr)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let user = HulaUser.sharedInstance
        if (user.token.characters.count>10){
            request.addValue(user.token, forHTTPHeaderField: "x-access-token")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print(error!)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response ?? "No response")
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            taskCallback(true, json as AnyObject?)
        }
        task.resume()
    }
    
    
    private func writeUserData(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent(HulaConstants.userFile + ".plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        //saving values
        
        let user = HulaUser.sharedInstance
        
        dict.setObject(user.token, forKey: "token" as NSCopying)
        dict.setObject(user.userId, forKey: "userId" as NSCopying)
        //...
        //writing to GameData.plist
        dict.write(toFile: path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved UserData.plist file is --> \(String(describing: resultDictionary?.description))")
        
        self.loadUserData()
    }
    
    
    func loadUserData() {
        // getting path to GameData.plist
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.appendingPathComponent(HulaConstants.userFile + ".plist")
        
        //        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        let fileManager = FileManager.default
        
        //check if file exists
        if(!fileManager.fileExists(atPath: path))
        {
            // If it doesn't, copy it from the default file in the Bundle
            
            if let bundlePath = Bundle.main.path(forResource: HulaConstants.userFile, ofType: "plist")
            {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle UserData.plist file is --> \(String(describing: resultDictionary?.description))")
                
                do
                {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                    print("copy")
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
            print("UserData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("Loaded UserData.plist file is --> \(String(describing: resultDictionary?.description))")
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            //loading values
            let user = HulaUser.sharedInstance
            
            user.token = dict.object(forKey: "token")! as! String
            user.userId = dict.object(forKey: "userId")! as! String
        }
        else
        {
            print("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        
    }//eom
}
