//
//  HLSearchResultViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSearchResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var productsResultsList: UIView!
    @IBOutlet var noResultAlertView: UIView!
    var searchByCategory: Bool = false;
    var categoryToSearch: NSDictionary = [:]
    var keywordToSearch: String = ""
    var productsResults: NSMutableDictionary = [:]
    var productsList: NSArray = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        
    }
    func initView(){
        noResultAlertView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getSearchResults()
    }
    
    //#MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 48.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight))
        let label = UILabel(frame: CGRect(x: 20.0, y:23.0, width: 200.0, height: 21.0))
        label.textColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1.0)
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "HelveticaNeue", size: 12.0)
        label.attributedText = commonUtils.attributedStringWithTextSpacing("SEARCH RESULTS", 2.33)
        view.addSubview(label)
        
        let lineLabel = UILabel(frame: CGRect(x: 0, y: tableView.sectionHeaderHeight - 1, width: tableView.frame.size.width, height: 1))
        lineLabel.backgroundColor = UIColor(red: 193.0/255, green: 193.0/255, blue: 193.0/255, alpha: 1.0)
        view.addSubview(lineLabel)
        view.backgroundColor = UIColor.white
        
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeProductCell") as! HLProductTableViewCell
        
        let product = productsList[indexPath.row] as! NSDictionary
        //print(product)
        cell.productName.text = product.object(forKey: "title") as? String
        commonUtils.loadImageOnView(imageView:cell.productImage, withURL:(product.object(forKey: "image_url") as? String)!)
        
        commonUtils.circleImageView(cell.productOwnerImage)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    
    // Custom functions for ViewController
    func getSearchResults() {
        //print("Getting user info...")
        var category_id = categoryToSearch.object(forKey: "_id") as? String
        if (category_id == nil){
            category_id = ""
        }
        let queryURL = HulaConstants.apiURL + "products/category/" + category_id!
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        
                        if let products = dictionary["products"] as? NSArray {
                            //print(products)
                            self.productsList = products
                        }
                    }
                    self.productsTableView.reloadData()
                    if (self.productsList.count == 0){
                        self.productsTableView.isHidden = true
                    } else {
                        self.productsTableView.isHidden = false
                    }
                }
            } else {
                // connection error
            }
        })
    }
}
