//
//  HulaUser.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

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
    var status: String!
    var location: CLLocation!
    var fbToken: String!
    var twToken: String!
    var liToken: String!
    var deviceId: String!
    var maxTrades: Int = 3
    var arrayProducts = [] as Array
    
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
        self.status = ""
        self.fbToken = ""
        self.twToken = ""
        self.liToken = ""
        self.deviceId = ""
        self.location = CLLocation(latitude: 0, longitude: 0)
        self.maxTrades = 3
        self.arrayProducts = []
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
        self.status = ""
        self.fbToken = ""
        self.twToken = ""
        self.liToken = ""
        self.maxTrades = 3
        self.deviceId = ""
        self.location = CLLocation(latitude: 0, longitude: 0)
        self.arrayProducts = []
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
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: getPostString(), isPut: true, taskCallback: { (ok, json) in
                
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
    
    func resendValidationMail(){
        print("Sending validation mail...")
        if(isUserLoggedIn()){
            let queryURL = HulaConstants.apiURL + "users/resend/" + self.userId
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: getPostString(), isPut: true, taskCallback: { (ok, json) in
                print("Message sent!")
                if (ok){
                    if let dictionary = json as? [String: Any] {
                        print(dictionary)
                    }
                    
                    //NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
                }
            })
        }
    }
    func getPostString() -> String {
        var str = "email=" + self.userEmail + "&name=" + self.userName + "&bio=" + self.userBio + "&nick=" + self.userNick + "&image=" + self.userPhotoURL + "&twtoken=" + self.twToken
        str = str + "&litoken=" + self.liToken + "&fbtoken=" + self.fbToken + "&push_device_id=" + self.deviceId
        
        if (self.location.coordinate.latitude != 0 && self.location.coordinate.longitude != 0){
           str = str + "&lat=\(self.location.coordinate.latitude)&lon=\(self.location.coordinate.longitude)&location_name=" + self.userLocationName
        }
        return str
    }
}
