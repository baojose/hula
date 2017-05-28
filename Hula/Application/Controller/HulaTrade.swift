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
    var date: Date = Date()
    var owner_products = [] as [String]
    var other_products = [] as [String]
    var next_bid: String!
    var status: String!
    
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
        self.owner_id = ""
        self.other_id = ""
        self.date = Date()
        self.owner_products = []
        self.other_products = []
        self.next_bid = ""
        self.status = "pending"
    }
    
    func saveNewTrade(){
        let queryURL = HulaConstants.apiURL + "trade"
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: "product_id=" + self.product_id + "&owner_id=" + self.owner_id + "&other_id=" + self.other_id + "&date=" + self.date.iso8601 + "&owner_products=" + self.owner_products.joined() + "&other_products=" + self.other_products.joined() + "&next_bid=" + self.next_bid + "&status=" + self.status, isPut: false, taskCallback: { (ok, json) in
            if (ok){
                //print(json!)
                if let dictionary = json as? NSDictionary {
                    print(dictionary)
                    if ((dictionary["id"] as? String) != nil){
                        self.tradeId = dictionary["id"] as! String
                    }
                }
            }
        })
    }
    
    func loadTrade(tradeId:String, callback: @escaping (Bool) -> ()){
        let queryURL = HulaConstants.apiURL + "trade/" + tradeId
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                if let loaded_trade = json as? NSDictionary {
                    // populate object
                    
                    if (loaded_trade["product_id"] as? String) != nil {
                        self.product_id = loaded_trade["product_id"] as? String
                    }
                    if (loaded_trade["owner_id"] as? String) != nil {
                        self.owner_id = loaded_trade["owner_id"] as? String
                    }
                    if (loaded_trade["other_id"] as? String) != nil {
                        self.other_id = loaded_trade["other_id"] as? String
                    }
                    if (loaded_trade["date"] as? String) != nil {
                        let str_date = loaded_trade["date"] as? String
                        self.date = (str_date?.dateFromISO8601)!
                    }
                    if (loaded_trade["owner_products"] as? [String]) != nil {
                        self.owner_products = (loaded_trade["owner_products"] as? [String])!
                    }
                    if (loaded_trade["other_products"] as? [String]) != nil {
                        self.owner_products = (loaded_trade["other_products"] as? [String])!
                    }
                    if (loaded_trade["next_bid"] as? String) != nil {
                        self.next_bid = loaded_trade["next_bid"] as? String
                    }
                    if (loaded_trade["status"] as? String) != nil {
                        self.status = loaded_trade["status"] as? String
                    }
                }
                // if success we will return true
                callback(true)
            } else {
                callback(false)
            }
        })
        
    }
    
    func updateServerData(){
        print("Updating trade...")
        if(tradeId.characters.count > 0){
            let queryURL = HulaConstants.apiURL + "trades/" + self.tradeId
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: "product_id=" + self.product_id + "&owner_id=" + self.owner_id + "&other_id=" + self.other_id + "&date=" + self.date.iso8601 + "&owner_products=" + self.owner_products.joined() + "&other_products=" + self.other_products.joined() + "&next_bid=" + self.next_bid + "&status=" + self.status, isPut: true, taskCallback: { (ok, json) in
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
