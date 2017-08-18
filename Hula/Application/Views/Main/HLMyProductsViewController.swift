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
    var spinner: HLSpinnerUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initData()
        self.initView()
        
        
        spinner = HLSpinnerUIView()
        self.view.addSubview(spinner)
        spinner.show(inView: self.view)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getUserProducts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    func initData(){
        
    }
    
    
    func initView(){
        NotificationCenter.default.addObserver(self, selector: #selector(HLMyProductsViewController.newPostModeDesign(_:)), name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        noProductsView.isHidden = true
    }
    
    
    //#MARK: - TableViewDelegate
    
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
                //commonUtils.loadImageOnView(imageView:cell.productImage, withURL:(mainProductImage))
                let thumb = commonUtils.getThumbFor(url: mainProductImage)
                //print(thumb)
                cell.productImage.loadImageFromURL(urlString: thumb)
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
        let order_sorted = self.arrayProducts.count - indexPath.row - 1
        goEditProductPage(index: order_sorted)
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
                    viewController.productImage = self.dataManager.newProduct.arrProductPhotos[0] as! UIImage
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
                //print(json)
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [Any] {
                            //print(dictionary)
                            self.arrayProducts = dictionary
                            self.spinner.hide()
                            HulaUser.sharedInstance.arrayProducts = dictionary
                            if (self.arrayProducts.count != 0){
                                self.noProductsView.isHidden = true
                            } else {
                                self.noProductsView.isHidden = false
                            }
                        } else {
                            let alert = UIAlertController(title: "User token expired", message: "Your Hula session is expired. Please log in again.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: {
                                //print("going to login page")
                                self.openUserIdentification()
                            })
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
        let product_images_array = dataManager.newProduct.arrProductPhotoLink.joined(separator: ",")
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
                                                //print(pos)
                                                self.arrayImagesURL[Int(pos)!] = HulaConstants.staticServerURL + filePath
                                                HLDataManager.sharedInstance.newProduct.arrProductPhotoLink = self.arrayImagesURL 
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
    
    func goEditProductPage(index: Int){
        //print(sender.tag)
        let productToDisplay : NSDictionary = self.arrayProducts[index] as! NSDictionary
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "editProductMainPage") as! HLEditProductMainViewController
        viewController.productToDisplay = productToDisplay
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
