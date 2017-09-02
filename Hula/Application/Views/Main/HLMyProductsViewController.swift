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
    var arrayProducts: [HulaProduct] = []
    var arrayImagesURL = ["","","",""] as Array
    var spinner: HLSpinnerUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initData()
        self.initView()
        
        
        self.getUserProducts()
        
        spinner = HLSpinnerUIView()
        self.view.addSubview(spinner)
        spinner.show(inView: self.view)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if dataManager.uploadMode == false {
            self.getUserProducts()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
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
        var order_sorted = self.arrayProducts.count - indexPath.row - 1
        if(order_sorted > self.arrayProducts.count){
            order_sorted = self.arrayProducts.count - 1
        }
        if(order_sorted < 0){
            order_sorted = 0
        }
        
        let product : HulaProduct = self.arrayProducts[order_sorted]
        //print(product)
        cell.productDescription.text = product.productName
        
        if (product.productImage.characters.count == 0){
            if (dataManager.newProduct.arrProductPhotos.count>0){
                if let img = dataManager.newProduct.arrProductPhotos.object(at: 0) as? UIImage {
                    cell.productImage.image = img
                } else {
                    cell.productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
                }
            } else {
                cell.productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
            }
        } else {
            let thumb = commonUtils.getThumbFor(url: product.productImage)
            cell.productImage.loadImageFromURL(urlString: thumb)
        }
        
        cell.warningView.isHidden = false
        if (product.productDescription != ""){
            cell.warningView.isHidden = true
        }
        let titleHeight: CGFloat! = commonUtils.heightString(width: cell.productDescription.frame.size.width, font: cell.productDescription.font, string: cell.productDescription.text!)
        cell.productDescription.frame = CGRect(x: cell.productDescription.frame.origin.x, y:(cell.contentView.frame.size.height - titleHeight) / 2.0, width: cell.productDescription.frame.size.width, height: titleHeight)
        

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        var order_sorted = self.arrayProducts.count - indexPath.row - 1
        if(order_sorted > self.arrayProducts.count){
            order_sorted = self.arrayProducts.count - 1
        }
        if(order_sorted < 0){
            order_sorted = 0
        }
        
        let product : HulaProduct = self.arrayProducts[order_sorted]
        if (product.productDescription == "" ){
            // product is incomplete
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "completeProductProfilePage") as! HLCompleteProductProfileViewController
            self.dataManager.newProduct = product
            self.present(viewController, animated: true)
            
            HLDataManager.sharedInstance.uploadMode = false
        } else {
            goEditProductPage(index: order_sorted)
        }
    }
    
    // IB Actions
    
    @IBAction func presentAddNewProductPage(_ sender: UIButton) {
        dataManager.uploadMode = true
        dataManager.newProduct = HulaProduct.init()
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "customCameraPage") as! HLCustomCameraViewController
        self.present(cameraViewController, animated: true)

    }
    
    
    // Custom functions for ViewController
    
    
    func newPostModeDesign(_ notification: NSNotification) {
        print("NewPostMode")
        print(HLDataManager.sharedInstance.newProduct.productId)
        print(dataManager.uploadMode)
        if dataManager.uploadMode == true {
            
            if HLDataManager.sharedInstance.newProduct.productId.characters.count > 0 && self.arrayProducts.count > 0{
                self.arrayProducts[self.arrayProducts.count  - 1] = dataManager.newProduct
                updateProduct()
            } else {
                self.arrayProducts.append(HLDataManager.sharedInstance.newProduct)
                //self.arrayProducts.insert(HLDataManager.sharedInstance.newProduct, at: 0)
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
            if let newcell = productTableView.cellForRow(at: IndexPath(item: 0, section: 0 )) as? HLMyProductTableViewCell{
                print("animationg...")
                newcell.animateAsNew()
            }
        }
    }
    
    func getUserProducts() {
        print("Getting product info...")
        if (HulaUser.sharedInstance.userId.characters.count>0){
            let queryURL = HulaConstants.apiURL + "products/user/" + HulaUser.sharedInstance.userId
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(json)
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [Any] {
                            print(dictionary)
                            let products_arr = dictionary
                            
                            self.arrayProducts = []
                            for pr in products_arr {
                                if let tmp = pr as? NSDictionary{
                                    let prod = HulaProduct()
                                    prod.populate(with: tmp)
                                    self.arrayProducts.append(prod)
                                }
                            }
                            
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
            //print(dataString)
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
        //print(HLDataManager.sharedInstance.newProduct.arrProductPhotoLink)
        //print(self.arrayImagesURL)
        let product_images_array = dataManager.newProduct.arrProductPhotoLink.joined(separator: ",")
        var dataString:String = "title=" + dataManager.newProduct.productName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&description=" + dataManager.newProduct.productDescription.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&condition=" + dataManager.newProduct.productCondition.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&category_id=" + dataManager.newProduct.productCategory.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&images=" + product_images_array.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&lat=\(HulaUser.sharedInstance.location.coordinate.latitude)"
        dataString += "&lng=\(HulaUser.sharedInstance.location.coordinate.longitude)"
        print(dataString)
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
                                //print("Uploaded!")
                                DispatchQueue.main.async {
                                    if let dictionary = json as? [String: Any] {
                                        //print(dictionary)
                                        if let filePath:String = dictionary["path"] as? String {
                                            //print(filePath)
                                            if let pos = dictionary["position"] as? String {
                                                //print(pos)
                                                self.arrayImagesURL[Int(pos)!] = HulaConstants.staticServerURL + filePath
                                                HLDataManager.sharedInstance.newProduct.arrProductPhotoLink = self.arrayImagesURL
                                                if Int(pos) == 0 {
                                                    HLDataManager.sharedInstance.newProduct.productImage = HulaConstants.staticServerURL + filePath
                                                }
                                                //print(self.arrayImagesURL[Int(pos)!])
                                                self.updateProduct()
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
        //let productToDisplay : HulaProduct = self.arrayProducts[index]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "editProductMainPage") as! HLEditProductMainViewController
        //viewController.productToDisplay = productToDisplay
        viewController.product = self.arrayProducts[index]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
