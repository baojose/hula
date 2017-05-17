//
//  HulaUser.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaUser: NSObject {
    
    var userId: String!
    var userName: String!
    var userNick: String!
    var userEmail: String!
    var userPhotoURL: String!
    var userLocationName: String!
    var userBio: String!
    var userPass: String!
    var token: String!
    var location: CGPoint!
    var fbToken: String!
    
    class var sharedInstance: HulaUser {
        struct Static {
            static let instance: HulaUser = HulaUser()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.userId = ""
        self.userNick = ""
        self.userName = ""
        self.userEmail = ""
        self.userPhotoURL = ""
        self.userLocationName = ""
        self.userPass = ""
        self.userBio = ""
        self.token = ""
        self.fbToken = ""
        self.location = CGPoint(x:0, y:0)
    }
    
    func isIncompleteProfile() -> Bool{
        var isIncomplete = false
        if (self.userName==""){
            isIncomplete = true
        }
        if (self.userNick==""){
            isIncomplete = true
        }
        if (self.userName==""){
            isIncomplete = true
        }
        if (self.userBio==""){
            isIncomplete = true
        }
        if (self.userPhotoURL==""){
            isIncomplete = true
        }
        return isIncomplete
    }
    func logout() {
        self.userId = ""
        self.userNick = ""
        self.userName = ""
        self.userEmail = ""
        self.userPhotoURL = ""
        self.userLocationName = ""
        self.userBio = ""
        self.userPass = ""
        self.token = ""
        self.fbToken = ""
        self.location = CGPoint(x:0, y:0)
    }
    
    func isUserLoggedIn() -> Bool{
        var isLoggedIn = false;
        if (self.userId.characters.count > 0) && (self.token.characters.count > 0) {
            isLoggedIn = true;
        }
        return isLoggedIn
    }
    
    func updateServerData(){
        print("Updating user...")
        if(isUserLoggedIn()){
            let queryURL = HulaConstants.apiURL + "users/" + self.userId
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: "email=" + self.userEmail + "&name=" + self.userName + "&bio=" + self.userBio + "&nick=" + self.userNick + "&image=" + self.userPhotoURL, isPut: true, taskCallback: { (ok, json) in
                
                //print("done")
                //print(ok)
                if (ok){
                    //print(json!)
                    if let dictionary = json as? [String: Any] {
                        print(dictionary)
                    }
                    
                    //NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
                }
            })
        }
    }
}
