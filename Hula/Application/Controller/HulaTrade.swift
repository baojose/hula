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
    
    func loadTrade(tradeId:String, callback: @escaping (Bool) -> ()){
        
        // if success we will return true
        callback(true)
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
