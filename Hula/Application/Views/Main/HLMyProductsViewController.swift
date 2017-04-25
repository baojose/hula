//
//  HLMyProductsViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLMyProductsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var productTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initData()
        self.initView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        let user = HulaUser.sharedInstance
        if (user.token.characters.count < 10){
            // user not logged in
            openUserIdentification()
        } else {
            self.getUserProducts()
        }
    }
    func initData(){
        
    }
    
    
    
    
    func getUserProducts() {
        
        //print("Getting user info...")
        let queryURL = HulaConstants.apiURL + "products/user/" + HulaUser.sharedInstance.userId
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [Any] {
                        print(dictionary)
                        /*
                        if let user = dictionary["user"] as? [String: Any] {
                            if (user["name"] as? String) != nil {
                                HulaUser.sharedInstance.userName = user["name"] as? String
                            }
                            if (user["nick"] as? String) != nil {
                                HulaUser.sharedInstance.userNick = user["nick"] as? String
                            }
                            if (user["bio"] as? String) != nil {
                                HulaUser.sharedInstance.userBio = user["bio"] as? String
                            }
                            if (user["email"] as? String) != nil {
                                HulaUser.sharedInstance.userEmail = user["email"] as? String
                            }
                            if (user["image"] as? String) != nil {
                                HulaUser.sharedInstance.userPhotoURL = user["image"] as? String
                                self.loadImageOnView(imageView:self.profileImageView, withURL:HulaUser.sharedInstance.userPhotoURL)
                            }
                        }
 */
                    }
                    
                    //self.userFullNameLabel.text = HulaUser.sharedInstance.userName
                    //self.userNickLabel.text = HulaUser.sharedInstance.userNick
                    //self.userBioLabel.text = HulaUser.sharedInstance.userBio
                    
                }
            } else {
                // connection error
            }
        })
    }
    func initView(){
        NotificationCenter.default.addObserver(self, selector: #selector(HLMyProductsViewController.newPostModeDesign(_:)), name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
    }
    
    @IBAction func presentAddNewProductPage(_ sender: UIButton) {
        print("button pressed")
        dataManager.uploadMode = true
        dataManager.newProduct = HulaProduct.init()
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "customCameraPage") as! HLCustomCameraViewController
        self.present(cameraViewController, animated: true)
    }
    func newPostModeDesign(_ notification: NSNotification) {
        productTableView.reloadData()
        productTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        if dataManager.uploadMode == true {
            let when = DispatchTime.now() + 3.0 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "completeProductProfilePage") as! HLCompleteProductProfileViewController
                self.present(viewController, animated: true)
            }
        }
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
        label.attributedText = commonUtils.attributedStringWithTextSpacing("YOUR INVENTORY", 2.33)
        view.addSubview(label)
        
        let lineLabel = UILabel(frame: CGRect(x: 0, y: tableView.sectionHeaderHeight - 1, width: tableView.frame.size.width, height: 1))
        lineLabel.backgroundColor = UIColor(red: 193.0/255, green: 193.0/255, blue: 193.0/255, alpha: 1.0)
        view.addSubview(lineLabel)
        view.backgroundColor = UIColor.white
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 128.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataManager.uploadMode == true {
            return 11
        }
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProductTableViewCell") as! HLMyProductTableViewCell
        cell.productEditBtn.addTarget(self, action: #selector(HLMyProductsViewController.goEditProductPage(_:)), for: .touchUpInside)
        if dataManager.uploadMode == true {
            if indexPath.row == 0 {
                cell.productImage.image = dataManager.newProduct.arrProductPhotos.object(at: 0) as? UIImage
                cell.productDescription.text = dataManager.newProduct.productName
                let titleHeight: CGFloat! = commonUtils.heightString(width: cell.productDescription.frame.size.width, font: cell.productDescription.font, string: cell.productDescription.text!)
                cell.productDescription.frame = CGRect(x: cell.productDescription.frame.origin.x, y:(cell.contentView.frame.size.height - titleHeight) / 2.0, width: cell.productDescription.frame.size.width, height: titleHeight)
                cell.warningView.frame = CGRect(x: cell.productDescription.frame.origin.x, y: cell.productDescription.frame.origin.y + cell.productDescription.frame.size.height + 4.0, width: cell.warningView.frame.size.width, height: cell.warningView.frame.size.height)
                cell.warningView.isHidden = false
                cell.productEditBtn.isHidden = true
            }else{
                let titleHeight: CGFloat! = commonUtils.heightString(width: cell.productDescription.frame.size.width, font: cell.productDescription.font, string: cell.productDescription.text!)
                cell.productDescription.frame = CGRect(x: cell.productDescription.frame.origin.x, y:(cell.contentView.frame.size.height - titleHeight) / 2.0, width: cell.productDescription.frame.size.width, height: titleHeight)
                cell.warningView.isHidden = true
                cell.productEditBtn.isHidden = false
            }
            return cell
        }else{
            let titleHeight: CGFloat! = commonUtils.heightString(width: cell.productDescription.frame.size.width, font: cell.productDescription.font, string: cell.productDescription.text!)
            cell.productDescription.frame = CGRect(x: cell.productDescription.frame.origin.x, y:(cell.contentView.frame.size.height - titleHeight) / 2.0, width: cell.productDescription.frame.size.width, height: titleHeight)
            cell.warningView.isHidden = true
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
    func goEditProductPage(_ sender: UIButton){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "editProductMainPage") as! HLEditProductMainViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
