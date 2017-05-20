//
//  HLHomeViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLHomeViewController: BaseViewController, UIScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var productTableView: UITableView!
    @IBOutlet var searchTxtField: UITextField!
    @IBOutlet var profileCompleteAlertView: UIView!
    @IBOutlet var noResultView: UIView!
    @IBOutlet var tableContainView: UIView!

    var isSearching: Bool!
    var productArray: NSMutableArray!
    var filteredKeywordsArray: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initData() {
        isSearching = false
        productArray = NSMutableArray.init()
        filteredKeywordsArray = NSMutableArray.init()
        for _ in 0 ..< 5 {
            productArray.add("Camera")
        }
        
        let categoriesLoaded = Notification.Name("categoriesLoaded")
        NotificationCenter.default.addObserver(self, selector: #selector(self.categoriesAreLoaded), name: categoriesLoaded, object: nil)

        
        self.initView()
    }
    func initView() {
        
        self.profileCompleteAlertView.isHidden = true;
        self.noResultView.isHidden = true;
        print(HulaUser.sharedInstance.userName)
        if (HulaUser.sharedInstance.userName == ""){
            //self.showProfileCompleteAlertView()
        }
        searchTxtField.addTarget(self, action: #selector(searchTextDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    
    //#MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 22.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight))
        let label = UILabel(frame: CGRect(x: 20, y:1, width: 200, height: tableView.sectionHeaderHeight - 2))
        label.textColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1.0)
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.attributedText = commonUtils.attributedStringWithTextSpacing("NEAR YOU", 2.33)
        view.addSubview(label)
        
        let lineLabel = UILabel(frame: CGRect(x: 0, y: tableView.sectionHeaderHeight - 1, width: tableView.frame.size.width, height: 1))
        lineLabel.backgroundColor = UIColor(red: 193.0/255, green: 193.0/255, blue: 193.0/255, alpha: 1.0)
        view.addSubview(lineLabel)
        view.backgroundColor = UIColor.white
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if self.isSearching == true{
            return 73.0
        }else{
            return 128.0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching == true {
            return filteredKeywordsArray.count
        }else{
            return dataManager.arrCategories.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isSearching == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeSearchCell") as! HLHomeSearchTableViewCell
            let keyword: String = filteredKeywordsArray.object(at: indexPath.row) as! String
            cell.productMainNameLabel.attributedText = commonUtils.attributedStringWithTextSpacing(keyword, CGFloat(1.0))
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCategoryCell") as! HLHomeCategoryTableViewCell
            let category : NSDictionary = dataManager.arrCategories.object(at: indexPath.row) as! NSDictionary
            
            cell.categoryName.attributedText = commonUtils.attributedStringWithTextSpacing(category.object(forKey: "name") as! String, CGFloat(2.33))
            cell.categoryImage.image = UIImage.init(named: category.object(forKey: "icon") as! String)
            cell.categoryProductNum.text = String(format:"%i products", (category.object(forKey: "num_products") as! Int))

            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let searchResultViewController = self.storyboard?.instantiateViewController(withIdentifier: "searchResultPage") as! HLSearchResultViewController
        if (isSearching){
            
            searchResultViewController.searchByCategory = false
            let category : NSDictionary = [:]
            searchResultViewController.categoryToSearch = category
            searchResultViewController.keywordToSearch = self.filteredKeywordsArray.object(at: indexPath.row) as! String
        } else {
            searchResultViewController.searchByCategory = true
            let category : NSDictionary = dataManager.arrCategories.object(at: indexPath.row) as! NSDictionary
            searchResultViewController.categoryToSearch = category
            searchResultViewController.keywordToSearch = ""
        }
        
        self.navigationController?.pushViewController(searchResultViewController, animated: true)
    }
    
    
    //#MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        isSearching = true
        self.searchProduct(textField.text!)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField.text?.characters.count == 0 {
            isSearching = false
            self.searchProduct(textField.text!)
        }else{
            isSearching = true
            self.searchProduct(textField.text!)
        }
        return textField.resignFirstResponder()
    }
    //#MARK: - ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if (scrollView == productTableView) {
            searchTxtField.resignFirstResponder()
        }
    }
    
    //#MARK - Web service - GetAllProduct
    func getAllProducts() {
        
    }
    
    
    // IB Actions
    
    @IBAction func closeProfileCompleteAlert(_ sender: Any) {
        self.hideProfileCompleteAlertView()
    }
    
    
    
    // Custom functions for ViewController
    
    func searchTextDidChange(_ textField:UITextField) {
        isSearching = true
        self.searchProduct(textField.text!)
    }
    
    
    func showProfileCompleteAlertView() {
        profileCompleteAlertView.isHidden = false;
        let newFrame: CGRect! = CGRect(x: HulaConstants.screenWidth / 8 * 7 - 282, y: HulaConstants.screenHeight - 136, width: 311, height: 78)
        profileCompleteAlertView.frame = CGRect(x: newFrame.origin.x + newFrame.size.width, y: newFrame.origin.y + newFrame.size.height, width: 0, height: 0)
        UIView.animate(withDuration: 0.2, animations: {
            self.profileCompleteAlertView.frame = newFrame
        }) { (finished: Bool!) in
            self.profileCompleteAlertView.isHidden = false;
        }
    }
    func hideProfileCompleteAlertView() {
        
        let newFrame: CGRect! = profileCompleteAlertView.frame
        self.profileCompleteAlertView.frame = newFrame
        UIView.animate(withDuration: 0.2, animations: {
            self.profileCompleteAlertView.frame = CGRect(x: newFrame.origin.x + newFrame.size.width, y: newFrame.origin.y + newFrame.size.height, width: 0, height: 0)
        }) { (finished: Bool!) in
            self.profileCompleteAlertView.isHidden = true;
        }
    }
    func categoriesAreLoaded(){
        print("Ya se ha cargado")
        refreshUI()
    }
    func refreshUI() {
        DispatchQueue.main.async(execute: {
            self.productTableView.reloadData()
        });
    }
    func searchProduct(_ searchString: String) {
        if isSearching == true {
            if searchString.characters.count == 0 {
                filteredKeywordsArray.removeAllObjects()
            }else{
                
                getKeywords(searchString.lowercased())
                
            }
        }
        productTableView.reloadData()
    }
    
    
    func getKeywords(_ kw:String) {
        //print("Getting keywords...")
        if (kw.characters.count > 1){
            let encodedKw = kw.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            let queryURL = HulaConstants.apiURL + "search/auto/" + encodedKw!   
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                self.filteredKeywordsArray.removeAllObjects()
                self.filteredKeywordsArray.add(kw)
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [String:Any] {
                            //print(dictionary)
                            if let keys = dictionary["keywords"] as?  [Any] {
                                for i in 0 ..< keys.count {
                                    let nkw = keys[i] as! [String:Any]
                                    let nkw_str = nkw["keyword"] as! String
                                    if (nkw_str != kw){
                                        self.filteredKeywordsArray.add(nkw_str)
                                    }
                                }
                            }
                        }
                        if self.filteredKeywordsArray.count == 0 {
                            self.noResultView.isHidden = false
                            self.tableContainView.isHidden = true
                        }else{
                            self.noResultView.isHidden = true
                            self.tableContainView.isHidden = false
                        }
                        self.productTableView.reloadData()
                    }
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }
}
