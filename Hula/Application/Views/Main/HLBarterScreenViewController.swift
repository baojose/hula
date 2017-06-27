//
//  HLBarterScreenViewController.swift
//  Hula
//
//  Created by Juan Searle on 13/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLBarterScreenViewController: UIViewController {

    @IBOutlet weak var myProductsTable: UITableView!
    @IBOutlet weak var otherProductsTable: UITableView!
    @IBOutlet weak var otherProductsDragView: UIImageView!
    @IBOutlet weak var myProductsDragView: UIImageView!
    @IBOutlet weak var otherProductsLabel: UILabel!
    @IBOutlet weak var myProductsLabel: UILabel!
    
    var myProducts : [Any] = []
    var otherProducts : [Any] = []
    var myTradedProducts : [String] = []
    var otherTradedProducts : [String] = []
    
    var otherUserId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            //print("viewWillAppear" )
            if let ct = swappPageVC.currentTrade {
                if (ct.object(forKey: "owner_id") as? String == HulaUser.sharedInstance.userId){
                    // I am the owner
                    myTradedProducts = (ct.object(forKey: "owner_products") as? [String])!
                    otherTradedProducts = (ct.object(forKey: "other_products") as? [String])!
                    otherUserId = (ct.object(forKey: "other_id") as? String)!
                    
                } else {
                    // I am the other
                    myTradedProducts = (ct.object(forKey: "other_products") as? [String])!
                    otherTradedProducts = (ct.object(forKey: "owner_products") as? [String])!
                    otherUserId = (ct.object(forKey: "owner_id") as? String)!
                }
                
                getUserProducts(user: otherUserId, taskCallback: {(result) in
                    self.otherProducts = result
                    print (self.otherProducts)
                    self.otherProductsTable.reloadData()
                    
                })
                getUserProducts(user: HulaUser.sharedInstance.userId, taskCallback: {(result) in
                    self.myProducts = result
                    //print (self.myProducts)
                    self.myProductsTable.reloadData()
                })
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getUserProducts(user: String, taskCallback: @escaping ([Any]) -> ()) {
        //print("Getting user info...")
        if (HulaUser.sharedInstance.userId.characters.count>0){
            let queryURL = HulaConstants.apiURL + "products/user/" + user
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [Any] {
                            //print(dictionary)
                            taskCallback(dictionary)
                        } else {
                            taskCallback([])
                        }
                    }
                } else {
                    // connection error
                    taskCallback([])
                }
            })
        }
    }
    
}

extension HLBarterScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.myProductsTable {
            return myProducts.count
        } else {
            return otherProducts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: HLSwappProductTableViewCell?
        if tableView == self.myProductsTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "swappcell") as? HLSwappProductTableViewCell
            if let prod = myProducts[indexPath.row] as? [String: Any]{
                if let prodTitle = prod["title"] as? String {
                    cell!.productName.text = prodTitle
                }
                if let prodImg = prod["image_url"] as? String {
                    cell!.productImage.loadImageFromURL(urlString: prodImg)
                }
            }
        }
        
        if tableView == self.otherProductsTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "swappcell2") as? HLSwappProductTableViewCell
            if let prod = otherProducts[indexPath.row] as? [String: Any]{
                if let prodTitle = prod["title"] as? String {
                    cell!.productName.text = prodTitle
                }
                if let prodImg = prod["image_url"] as? String {
                    cell!.productImage.loadImageFromURL(urlString: prodImg)
                }
            }
            
        }
        
        
        return cell!
    }
}
