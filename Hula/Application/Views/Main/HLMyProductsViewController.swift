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
    @IBOutlet weak var noProductsView: UIView!
    var arrayProducts = [] as Array
    var arrayImagesURL = ["","","",""] as Array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initData()
        self.initView()
        self.getUserProducts()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        /*
        let user = HulaUser.sharedInstance
        if (user.token.characters.count < 10){
            // user not logged in
            openUserIdentification()
        } else {
            //self.getUserProducts()
        }
 */
    }
    func initData(){
        
    }
    
    
    func initView(){
        NotificationCenter.default.addObserver(self, selector: #selector(HLMyProductsViewController.newPostModeDesign(_:)), name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        noProductsView.isHidden = true
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
        if (self.arrayProducts.count != 0){
            return self.arrayProducts.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProductTableViewCell") as! HLMyProductTableViewCell
        let order_sorted = self.arrayProducts.count - indexPath.row - 1
        cell.productEditBtn.tag = order_sorted
        cell.productEditBtn.addTarget(self, action: #selector(goEditProductPage), for: .touchUpInside)
        
        let product : NSDictionary = self.arrayProducts[order_sorted] as! NSDictionary
        //print(product)
        if let productTitle = product.object(forKey: "title") as? String {
            cell.productDescription.text = productTitle
        } else {
            cell.productDescription.text = "Untitled product"
        }
        if (product.object(forKey: "image_url") as? String == ""){
            if let product_image = product.object(forKey: "image") as? UIImage {
                cell.productImage.image = product_image
            }
        } else {
            if let mainProductImage = product.object(forKey: "image_url") as? String {
                commonUtils.loadImageOnView(imageView:cell.productImage, withURL:(mainProductImage))
            }
        }
        
        cell.warningView.isHidden = false
        if let desc = product.object(forKey: "description") as? String {
            //print("Hidden")
            if (desc != ""){
                cell.warningView.isHidden = true
            }
        }
        let titleHeight: CGFloat! = commonUtils.heightString(width: cell.productDescription.frame.size.width, font: cell.productDescription.font, string: cell.productDescription.text!)
        cell.productDescription.frame = CGRect(x: cell.productDescription.frame.origin.x, y:(cell.contentView.frame.size.height - titleHeight) / 2.0, width: cell.productDescription.frame.size.width, height: titleHeight)
        
        if (indexPath.row == 0 && dataManager.uploadMode == true ){
            cell.animateAsNew()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
    
    // IB Actions
    
    @IBAction func presentAddNewProductPage(_ sender: UIButton) {

        
        
        //print("button pressed")
        dataManager.uploadMode = true
        dataManager.newProduct = HulaProduct.init()
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "customCameraPage") as! HLCustomCameraViewController
        self.present(cameraViewController, animated: true)

    }
    
    
    // Custom functions for ViewController
    
    
    func newPostModeDesign(_ notification: NSNotification) {
        if dataManager.uploadMode == true {
            var newProduct = [String : AnyObject]()
            newProduct["title"] = dataManager.newProduct.productName as AnyObject
            newProduct["image"] = dataManager.newProduct.arrProductPhotos[0] as AnyObject
            newProduct["image_url"] = "" as AnyObject
            newProduct["description"] = dataManager.newProduct.productDescription as AnyObject
            newProduct["condition"] = dataManager.newProduct.productCondition as AnyObject
            
            if (HLDataManager.sharedInstance.newProduct.productId.characters.count>0){
                self.arrayProducts[self.arrayProducts.count  - 1] = newProduct
                updateProduct()
            } else {
                self.arrayProducts.append(newProduct)
                uploadImages()
                uploadProduct()
                let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "completeProductProfilePage") as! HLCompleteProductProfileViewController
                    self.present(viewController, animated: true)
                    
                    HLDataManager.sharedInstance.uploadMode = false
                }
            }
            productTableView.reloadData()
            productTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            
        }
    }
    
    func getUserProducts() {
        //print("Getting user info...")
        if (HulaUser.sharedInstance.userId.characters.count>0){
            let queryURL = HulaConstants.apiURL + "products/user/" + HulaUser.sharedInstance.userId
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [Any] {
                            //print(dictionary)
                            self.arrayProducts = dictionary
                            HulaUser.sharedInstance.arrayProducts = dictionary
                            if (self.arrayProducts.count != 0){
                                self.noProductsView.isHidden = true
                            } else {
                                self.noProductsView.isHidden = false
                            }
                        }
                        self.productTableView.reloadData()
                    }
                } else {
                    // connection error
                    //print("Connection error")
                    self.noProductsView.isHidden = true
                }
            })
        }
    }
    func uploadProduct() {
        //print("Saving product...")
        if (HulaUser.sharedInstance.userId.characters.count>0){
            let queryURL = HulaConstants.apiURL + "products/"
            let dataString:String = updateProductDataString()
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        //print("Saved")
                        if let dictionary = json as? [String:Any] {
                            print(dictionary)
                            if let product_id = dictionary["product_id"] as? String {
                                HLDataManager.sharedInstance.newProduct.productId = product_id
                            }
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
    func updateProduct() {
        print("Updating product...")
        if (HLDataManager.sharedInstance.newProduct.productId.characters.count>0){
            let queryURL = HulaConstants.apiURL + "products/" + HLDataManager.sharedInstance.newProduct.productId
            let dataString:String = updateProductDataString()
            print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [String:Any] {
                            print(dictionary)
                        }
                        HLDataManager.sharedInstance.uploadMode = false
                        self.productTableView.reloadData()
                    }
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }
    
    func updateProductDataString() -> String{
        print(HLDataManager.sharedInstance.newProduct.arrProductPhotoLink)
        print(self.arrayImagesURL)
        let product_images_array = dataManager.newProduct.arrProductPhotoLink.componentsJoined(by: ",")
        var dataString:String = "title=" + dataManager.newProduct.productName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&description=" + dataManager.newProduct.productDescription.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&condition=" + dataManager.newProduct.productCondition.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&category_id=" + dataManager.newProduct.productCategory.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&images=" + product_images_array.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&lat=40"
        dataString += "&lng=-3"
        return dataString
    }
    
    func uploadImages() {
        //print("Getting user info...")
        print("Uploading images...")
        if (HulaUser.sharedInstance.userId.characters.count>0){
            for i in 0 ..< 4{
                if ( dataManager.newProduct.arrProductPhotos.count>i ){
                    if (dataManager.newProduct.arrProductPhotos[i] as? UIImage != nil){
                        dataManager.uploadImage(dataManager.newProduct.arrProductPhotos[i] as! UIImage, itemPosition:i, taskCallback: { (ok, json) in
                            if (ok){
                                print("Uploaded!")
                                DispatchQueue.main.async {
                                    if let dictionary = json as? [String: Any] {
                                        print(dictionary)
                                        if let filePath:String = dictionary["path"] as? String {
                                            print(filePath)
                                            if let pos = dictionary["position"] as? String {
                                                print(pos)
                                                self.arrayImagesURL[Int(pos)!] = HulaConstants.staticServerURL + filePath
                                                HLDataManager.sharedInstance.newProduct.arrProductPhotoLink = self.arrayImagesURL as! NSMutableArray
                                                print(self.arrayImagesURL[Int(pos)!])
                                            }
                                        }
                                    }
                                }
                            } else {
                                // connection error
                                print("Connection error")
                            }
                        });
                    }
                }
            }
        }
    }
    
    func goEditProductPage(sender: UIButton){
        //print(sender.tag)
        let productToDisplay : NSDictionary = self.arrayProducts[sender.tag] as! NSDictionary
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "editProductMainPage") as! HLEditProductMainViewController
        viewController.productToDisplay = productToDisplay
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
