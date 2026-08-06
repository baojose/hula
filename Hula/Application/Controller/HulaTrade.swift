//
//  HulaSwapp.swift
//  Hula
//
//  Created by Juan Searle on 28/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaTrade: NSObject {
    var tradeId: String!
    var product_id: String!
    var owner_id: String!
    var other_id: String!
    var other_agree: Bool = false
    var other_ready: Bool = false
    var owner_ready: Bool = false
    var date: Date = Date()
    var last_update: Date = Date()
    var owner_products = [] as [String]
    var other_products = [] as [String]
    var owner_money : Float = 0.0
    var other_money : Float = 0.0
    var owner_unread : Int = 0
    var other_unread : Int = 0
    var owner_accepted : Bool = false
    var other_accepted : Bool = false
    var next_bid: String!
    var status: String!
    var turn_user_id: String!
    var last_bid_diff:[String] = []
    var num_bids:Int = 0
    
    
    class var sharedInstance: HulaTrade {
        struct Static {
            static let instance: HulaTrade = HulaTrade()
        }
        return Static.instance
    }
    
    
    override init() {
        super.init()
        self.tradeId = ""
        self.product_id = ""
        self.other_agree = false
        self.owner_id = ""
        self.other_id = ""
        self.owner_ready = false
        self.other_ready = false
        self.date = Date()
        self.last_update = Date()
        self.owner_products = []
        self.other_products = []
        self.owner_money = 0.0
        self.other_money = 0.0
        self.owner_unread = 0
        self.other_unread = 0
        self.owner_accepted = false
        self.other_accepted = false
        self.next_bid = ""
        self.turn_user_id = ""
        self.status = "pending"
        self.last_bid_diff = []
        self.num_bids = 0
    }
    
    func saveNewTrade(){
        let queryURL = HulaConstants.apiURL + "trades"
        let post_string = get_post_string();
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: post_string, isPut: false, taskCallback: { (ok, json) in
            if (ok){
                //print(json!)
                if let dictionary = json as? NSDictionary {
                    //print(dictionary)
                    if let newId = dictionary["id"] as? String, newId.count > 0 {
                        self.tradeId = newId
                    }
                }
            }
        })
    }
    
    func get_post_string() -> String {
        let ownerProducts = CommonUtils.formEncodedValue(self.owner_products.joined(separator: ","))
        let otherProducts = CommonUtils.formEncodedValue(self.other_products.joined(separator: ","))
        return "product_id=" + CommonUtils.formEncodedValue(self.product_id)
            + "&owner_id=" + CommonUtils.formEncodedValue(self.owner_id)
            + "&other_id=" + CommonUtils.formEncodedValue(self.other_id)
            + "&date=" + CommonUtils.formEncodedValue(self.date.iso8601)
            + "&owner_products=" + ownerProducts
            + "&other_products=" + otherProducts
            + "&next_bid=" + CommonUtils.formEncodedValue(self.next_bid)
            + "&status=" + CommonUtils.formEncodedValue(self.status)
            + "&turn_user_id=" + CommonUtils.formEncodedValue(self.turn_user_id)
            + "&owner_money=\(self.owner_money)&other_money=\(self.other_money)"
    }

    /// Map trade cash onto the UI "owner"/my side vs "other" side for the current viewer.
    func money(forSide side: String, viewerIsOwner: Bool) -> Float {
        switch side {
        case "other":
            return viewerIsOwner ? other_money : owner_money
        default:
            return viewerIsOwner ? owner_money : other_money
        }
    }
    
    func loadTrade(tradeId:String, callback: @escaping (Bool) -> ()){
        let queryURL = HulaConstants.apiURL + "trades/" + tradeId
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                if let loaded_trade = json as? NSDictionary {
                    // populate object
                    self.loadFrom(dict: loaded_trade)
                }
                // if success we will return true
                callback(true)
            } else {
                callback(false)
            }
        })
        
    }
    func loadFrom(dict: NSDictionary){
        if (dict["_id"] as? String) != nil {
            self.tradeId = dict["_id"] as? String
        }
        if (dict["product_id"] as? String) != nil {
            self.product_id = dict["product_id"] as? String
        }
        if (dict["owner_id"] as? String) != nil {
            self.owner_id = dict["owner_id"] as? String
        }
        if (dict["other_id"] as? String) != nil {
            self.other_id = dict["other_id"] as? String
        }
        if let flag = CommonUtils.boolFromJSON(dict["other_agree"]) {
            self.other_agree = flag
        }
        if let flag = CommonUtils.boolFromJSON(dict["other_ready"]) {
            self.other_ready = flag
        }
        if let flag = CommonUtils.boolFromJSON(dict["owner_ready"]) {
            self.owner_ready = flag
        }
        if let str_date = dict["date"] as? String, let parsed = str_date.dateFromISO8601 {
            self.date = parsed
        }
        if (dict["owner_products"] as? [String]) != nil {
            self.owner_products = (dict["owner_products"] as? [String])!
        }
        if (dict["other_products"] as? [String]) != nil {
            self.other_products = (dict["other_products"] as? [String])!
        }
        if let money = CommonUtils.floatFromJSON(dict["owner_money"]) {
            self.owner_money = money
        }
        if let money = CommonUtils.floatFromJSON(dict["other_money"]) {
            self.other_money = money
        }
        if (dict["next_bid"] as? String) != nil {
            self.next_bid = dict["next_bid"] as? String
        }
        if (dict["status"] as? String) != nil {
            self.status = dict["status"] as? String
        }
        if (dict["turn_user_id"] as? String) != nil {
            self.turn_user_id = dict["turn_user_id"] as? String
        }
        if let str_date = dict["last_update"] as? String, let parsed = str_date.dateFromISO8601 {
            self.last_update = parsed
        }
        if let unread = CommonUtils.intFromJSON(dict["owner_unread"]) {
            self.owner_unread = unread
        } else {
            self.owner_unread = 0
        }
        if let unread = CommonUtils.intFromJSON(dict["other_unread"]) {
            self.other_unread = unread
        } else {
            self.other_unread = 0
        }
        if let flag = CommonUtils.boolFromJSON(dict["owner_accepted"]) {
            self.owner_accepted = flag
        } else {
            self.owner_accepted = false
        }
        if let flag = CommonUtils.boolFromJSON(dict["other_accepted"]) {
            self.other_accepted = flag
        } else {
            self.other_accepted = false
        }
        
        //print(dict)
        self.last_bid_diff = []
        self.num_bids = 0
        if let bids = dict["bids"] as? [Any] {
            self.num_bids = bids.count
            if let last_bid = bids.last as? [String:Any]{
                //print(last_bid)
                if let lb_owner = last_bid["owner_diff"] as? [String]{
                    for item in lb_owner {
                        self.last_bid_diff.append(item)
                    }
                }
                if let lb_other = last_bid["other_diff"] as? [String]{
                    for item in lb_other {
                        self.last_bid_diff.append(item)
                    }
                }
            }
        }
        //print(self.last_bid_diff)
    }

    func updateServerData(){
        //print("Updating trade...")
        if(tradeId.count > 0){
            let queryURL = HulaConstants.apiURL + "trades/" + self.tradeId
            let post_string = get_post_string();
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: post_string, isPut: true, taskCallback: { (ok, json) in
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
    
    override var description : String {
        return "**** Hula Trade - owner: \(self.owner_id) and other:   \(self.other_id)****\n"
    }
}
